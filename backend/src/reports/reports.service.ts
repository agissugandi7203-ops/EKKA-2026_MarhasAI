import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { GcsService } from '../storage/gcs.service';
import { PiiRedactionService } from '../storage/pii-redaction.service';

@Injectable()
export class ReportsService {
  constructor(
    private supabaseService: SupabaseService,
    private gcsService: GcsService,
    private piiRedactionService: PiiRedactionService,
  ) {}

  async createReport(
    userId: string,
    fileBuffer: Buffer,
    fileMimeType: string,
    lat: number,
    lng: number,
    description?: string,
  ) {
    const supabase = this.supabaseService.getClient();

    // 1. Cek duplikasi spasial menggunakan PostGIS RPC
    const { data: duplicateId, error: rpcError } = await supabase.rpc('check_duplicate_report', {
      p_lat: lat,
      p_lng: lng,
    });

    if (rpcError) {
      throw new BadRequestException('Gagal memverifikasi lokasi spasial: ' + rpcError.message);
    }

    if (duplicateId) {
      return {
        isDuplicate: true,
        message: 'Laporan serupa terdeteksi dalam radius 50 meter. Menggabungkan laporan...',
        duplicateReportId: duplicateId,
      };
    }

    // 2. Lakukan sensor gambar PII (Wajah & Plat Nomor)
    const sanitizedBuffer = await this.piiRedactionService.redactSensitiveInfo(fileBuffer);

    // 3. Buat nama file unik untuk diunggah ke Google Cloud Storage
    const fileExtension = fileMimeType.split('/')[1] || 'jpg';
    const uniqueFileName = `reports/${userId}/${Date.now()}_${Math.random().toString(36).substring(2, 7)}.${fileExtension}`;

    // 4. Unggah ke Google Cloud Storage
    let imageUrl: string;
    try {
      imageUrl = await this.gcsService.uploadFile(sanitizedBuffer, uniqueFileName, fileMimeType);
    } catch (gcsError) {
      throw new BadRequestException('Gagal mengunggah foto laporan ke storage: ' + gcsError.message);
    }

    // 5. Simpan data laporan spasial ke database Supabase
    const { data: report, error: insertError } = await supabase
      .from('reports')
      .insert({
        reporter_id: userId,
        image_url: imageUrl,
        description: description || '',
        location: `SRID=4326;POINT(${lng} ${lat})`, // WKT PostGIS Point
        status: 'pending_ai', // Klasifikasi AI berjalan di Fitur 4
      })
      .select()
      .single();

    if (insertError || !report) {
      throw new BadRequestException('Gagal menyimpan laporan ke database: ' + insertError?.message);
    }

    return {
      isDuplicate: false,
      message: 'Laporan berhasil diunggah dan disimpan',
      report,
    };
  }

  async getReports() {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('reports')
      .select('*, profiles(username, full_name, avatar_url)')
      .order('created_at', { ascending: false });

    if (error) {
      throw new BadRequestException('Failed to fetch reports: ' + error.message);
    }
    return data || [];
  }
}
