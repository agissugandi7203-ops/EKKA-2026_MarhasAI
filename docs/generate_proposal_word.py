"""
Generator Dokumen Word — Subbab 1.4 dan 1.5 Proposal Genesis
Sesuai Standar LKS Nasional 2026 dan KBBI (Margin 4-3-3-3, 1.5 Spasi, TNR 12, Maks 2 Halaman)
"""
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
import os

OUTPUT = r"d:\PROJECT ARIEF\LKS Dikdasmen\docs\Proposal_Teknis_Genesis.docx"

# Konstanta Format Dokumen (Ukuran standar)
FONT_NAME = "Times New Roman"
SIZE_BODY = Pt(12)
SIZE_HEADING = Pt(12)
SIZE_TABLE_TEXT = Pt(10)
LINE_SPACING_BODY = 1.5
LINE_SPACING_TABLE = 1.15

COLOR_BLACK = RGBColor(0x00, 0x00, 0x00)
COLOR_GRAY = RGBColor(0x33, 0x33, 0x33)

HEX_BORDER = "CCCCCC" # Warna batas abu-abu terang untuk tabel sederhana
HEX_HEADER_BG = "F2F2F2" # Latar belakang header abu-abu terang

def style_cell(cell, top_padding=100, bottom_padding=100, left_padding=120, right_padding=120, 
               shading_color=None, border_color=HEX_BORDER, v_align="center"):
    """Mengatur padding internal standar, shading, border grid tipis, dan perataan vertikal tengah."""
    tcPr = cell._tc.get_or_add_tcPr()
    
    # 1. Padding Sel Standar (100 dxa = 5pt atas/bawah)
    tcMar = parse_xml(
        f'<w:tcMar {nsdecls("w")}>'
        f'  <w:top w:w="{top_padding}" w:type="dxa"/>'
        f'  <w:bottom w:w="{bottom_padding}" w:type="dxa"/>'
        f'  <w:left w:w="{left_padding}" w:type="dxa"/>'
        f'  <w:right w:w="{right_padding}" w:type="dxa"/>'
        f'</w:tcMar>'
    )
    tcPr.append(tcMar)
    
    # 2. Shading Sel
    if shading_color:
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{shading_color}"/>')
        tcPr.append(shd)
        
    # 3. Border Grid Sederhana (Semua sisi)
    for el in list(tcPr):
        if el.tag.endswith('tcBorders'):
            tcPr.remove(el)
    borders_xml = parse_xml(
        f'<w:tcBorders {nsdecls("w")}>'
        f'  <w:top w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>'
        f'  <w:bottom w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>'
        f'  <w:left w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>'
        f'  <w:right w:val="single" w:sz="4" w:space="0" w:color="{border_color}"/>'
        f'</w:tcBorders>'
    )
    tcPr.append(borders_xml)
    
    # 4. Perataan Vertikal Tengah (Vertical Centering)
    for el in list(tcPr):
        if el.tag.endswith('vAlign'):
            tcPr.remove(el)
    v_align_xml = parse_xml(f'<w:vAlign {nsdecls("w")} w:val="{v_align}"/>')
    tcPr.append(v_align_xml)

def write_cell(cell, text, bold=False, italic=False, align=WD_ALIGN_PARAGRAPH.LEFT):
    cell.text = ""
    p = cell.paragraphs[0]
    p.alignment = align
    pf = p.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)
    pf.line_spacing = LINE_SPACING_TABLE
    
    # Memproses format miring otomatis pada istilah bahasa Inggris di dalam sel
    words = text.split(" ")
    for word in words:
        run = p.add_run(word + " ")
        run.font.name = FONT_NAME
        run.font.size = SIZE_TABLE_TEXT
        run.font.color.rgb = COLOR_BLACK
        run.bold = bold
        
        # Deteksi istilah asing/teknis untuk otomatis dicetak miring
        is_english = italic or any(term in word.lower() for term in [
            "multipart", "in-memory", "blur", "embedding", "streaming", "routing", 
            "check_duplicate_report", "pgvector", "hnsw", "whisper", "client", "record", 
            "geolocator", "database", "vision", "sharp", "flash", "openrouter", "throttler", 
            "jwt", "rbac", "rate", "limiting", "injection", "evasion", "typoglycemia", 
            "active", "learning", "feedback", "loop", "upvote", "design", "hitl", "gateway",
            "support", "similarity", "pending_human"
        ])
        run.italic = is_english

        rPr = run._element.get_or_add_rPr()
        rFonts = rPr.find(qn('w:rFonts'))
        if rFonts is None:
            rFonts = parse_xml(f'<w:rFonts {nsdecls("w")} w:eastAsia="{FONT_NAME}"/>')
            rPr.append(rFonts)

def add_heading(doc, num, title):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pf = p.paragraph_format
    pf.space_before = Pt(12)
    pf.space_after = Pt(4)
    pf.line_spacing = 1.15
    pf.keep_with_next = True
    
    run = p.add_run(f"{num} {title}")
    run.font.name = FONT_NAME
    run.font.size = SIZE_HEADING
    run.font.color.rgb = COLOR_BLACK
    run.bold = True

def add_paragraph(doc, segments, space_after=Pt(0)):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    pf = p.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = space_after
    pf.line_spacing = LINE_SPACING_BODY
    pf.first_line_indent = Cm(1.27)
    
    for txt, b, i in segments:
        run = p.add_run(txt)
        run.font.name = FONT_NAME
        run.font.size = SIZE_BODY
        run.font.color.rgb = COLOR_BLACK
        run.bold = b
        run.italic = i
    return p

def add_caption(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    pf = p.paragraph_format
    pf.space_before = Pt(3)
    pf.space_after = Pt(6)
    pf.line_spacing = 1.0
    
    run = p.add_run(text)
    run.font.name = FONT_NAME
    run.font.size = Pt(9.5)
    run.font.color.rgb = COLOR_GRAY
    run.italic = True

def build_simple_table(doc, headers, data, col_widths):
    """Membangun tabel sederhana dengan kolom NO dan pembatas lengkap."""
    tbl = doc.add_table(rows=len(data) + 1, cols=len(headers))
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl.autofit = False
    
    # Header Row
    for col_idx, text in enumerate(headers):
        cell = tbl.rows[0].cells[col_idx]
        write_cell(cell, text, bold=True, align=WD_ALIGN_PARAGRAPH.CENTER)
        style_cell(cell, shading_color=HEX_HEADER_BG)
    
    # Data Rows
    for row_idx, row_data in enumerate(data):
        row = tbl.rows[row_idx + 1]
        for col_idx, val in enumerate(row_data):
            cell = row.cells[col_idx]
            
            # Kolom NO rata tengah, kolom lainnya rata kiri
            bold = (col_idx == 0) or (col_idx == 1)
            align = WD_ALIGN_PARAGRAPH.CENTER if col_idx == 0 else WD_ALIGN_PARAGRAPH.LEFT
            
            write_cell(cell, val, bold=bold, align=align)
            style_cell(cell)
                
    # Atur Lebar Kolom (Total tepat 14.0 cm untuk menjaga kelurusan dengan margin)
    for row in tbl.rows:
        for col_idx, width in enumerate(col_widths):
            row.cells[col_idx].width = Cm(width)
            
    return tbl


# ══════════════════════════════════════════════════════════════
# DOKUMEN SETUP (Margin 4-3-3-3 Sesuai Standar LKS)
# ══════════════════════════════════════════════════════════════
doc = Document()
sec = doc.sections[0]
sec.page_width = Cm(21.0)
sec.page_height = Cm(29.7)
sec.top_margin = Cm(3.0)      # Atas: 3 cm
sec.bottom_margin = Cm(3.0)   # Bawah: 3 cm
sec.left_margin = Cm(4.0)     # Kiri: 4 cm (untuk jilid)
sec.right_margin = Cm(3.0)    # Kanan: 3 cm

# ══════════════════════════════════════════════════════════════
# 1.4 PENDEKATAN TEKNIS DAN SUMBER DATA
# ══════════════════════════════════════════════════════════════
add_heading(doc, "1.4", "Pendekatan Teknis dan Sumber Data")

add_paragraph(doc, [
    ("Genesis adalah platform aksi iklim lokal dengan arsitektur multiplatform: Flutter (BLoC), Next.js, "
     "dan NestJS pada Google Cloud Platform (GCP). Tim menggunakan ", False, False),
    ("Google Antigravity sebagai AI coding assistant", True, False),
     (" untuk dokumentasi dan optimasi kode, sementara perancangan arsitektur dan pengujian dilakukan mandiri. "
      "Berbeda dengan sistem konvensional, Genesis menerapkan validasi otomatis, sensor data sensitif, dan analisis AI sebelum laporan masuk ke dinas. "
      "Pendekatan ini meningkatkan kualitas data pemerintah daerah sekaligus mempercepat keputusan petugas Dinas Lingkungan Hidup. "
      "Alur data dirangkum pada Tabel 1.", False, False),
])

# ── Tabel 1: Alur Kerja Sistem (Input, Proses, Output) ──
build_simple_table(doc,
    ["No.", "Tahap", "Aktivitas Teknis", "Implementasi Teknologi"],
    [
        ("1",
         "Input Data",
         "Warga mengambil foto lokasi sampah secara langsung via mobile, yang otomatis melampirkan koordinat GPS.",
         "Sensor kamera dan sensor GPS perangkat mobile."),
        
        ("2",
         "Sanitasi Data",
         "Deduplikasi laporan (radius 50m). Deteksi dan sensor otomatis wajah/plat nomor pada gambar di memori server.",
         "Postgres/PostGIS, Google Vision API, dan Sharp (in-memory blur)."),
        
        ("3",
         "Analisis AI",
         "AI menganalisis foto untuk klasifikasi jenis sampah, tingkat keparahan, dan rekomendasi mitigasi.",
         "Gemini 3.5 Flash menghasilkan keluaran terstruktur dalam format JSON."),
        
        ("4",
         "Output Data",
         "Peta laporan tersensor di dasbor admin, poin gamifikasi warga, dan chatbot regulasi dengan input suara.",
         "pgvector HNSW, Gemini Embedding, Whisper-1 (transkripsi chatbot), Server-Sent Events (SSE).")
    ],
    [1.0, 2.5, 5.5, 5.0] # Total: 14.0 cm
)
add_caption(doc, "Tabel 1. Alur input, proses, dan output pemrosesan data AI pada Genesis.")

# ── Paragraf Alur Teknis ──
add_paragraph(doc, [
    ("Alur kerja diawali deteksi duplikasi via ", False, False),
    ("check_duplicate_report()", False, True),
    (" di PostGIS (radius 50m, jeda 12h) agar laporan warga yang berlokasi sama digabungkan sebagai upvote. Laporan baru disensor oleh "
     "Google Vision API untuk mencari koordinat wajah/plat nomor, diburamkan secara permanen via Sharp di memori server guna melindungi "
     "identitas pengguna sebelum data disimpan di Google Cloud Storage (GCS), sedangkan foto dianalisis oleh Gemini 3.5 Flash untuk klasifikasi sampah. "
     "Laporan berskor keyakinan >= 85% disetujui otomatis dengan poin gamifikasi, sedangkan skor < 85% berstatus ", False, False),
    ("\"pending_human\"", False, True),
     (" untuk divalidasi manual oleh petugas Dinas Lingkungan Hidup via Next.js. Warga juga dapat berkonsultasi seputar regulasi lingkungan hidup "
      "melalui chatbot berbasis Retrieval-Augmented Generation (RAG) yang mendukung kueri suara dengan transkripsi Whisper-1. Sistem mencari pasal di pgvector "
      "via cosine similarity, lalu mengirim respons streaming via SSE untuk menjamin validitas rujukan hukum. Alur ini mereduksi verifikasi administratif agar "
      "petugas fokus pada penanganan lapangan. Sumber data dirangkum pada Tabel 2.", False, False)
])

# ── Tabel 2: Sumber Data & Batasan Data dengan Kolom NO ──
build_simple_table(doc,
    ["No.", "Kategori Data", "Format Data", "Sumber Perolehan", "Batasan dan Keamanan Data"],
    [
        ("1",
         "Partisipasi Publik",
         "GPS, JPEG/PNG, M4A",
         "Sensor dan perekam audio perangkat mobile",
         "Seluruh data uji berasal dari perangkat pengembang dan tidak menyimpan informasi identitas pribadi (Personally Identifiable Information, PII)."),
        
        ("2",
         "Regulasi Daerah",
         "PDF / Markdown",
         "Portal data terbuka pemerintah",
         "Menggunakan dokumen resmi Perda, UU, dan PP lingkungan hidup yang tersedia publik."),
        
        ("3",
         "Data Historis",
         "Relasional SQL",
         "PostgreSQL (Supabase)",
         "Data samaran username warga dan poin gamifikasi tanpa informasi sensitif.")
    ],
    [1.0, 2.8, 2.2, 3.5, 4.5] # Total: 14.0 cm
)
add_caption(doc, "Tabel 2. Klasifikasi sumber data dan batasan keamanan data Genesis.")


# ══════════════════════════════════════════════════════════════
# 1.5 RESPONSIBLE AI
# ══════════════════════════════════════════════════════════════
add_heading(doc, "1.5", "Responsible AI")

add_paragraph(doc, [
    ("Genesis menerapkan prinsip etika AI sejak awal perancangan sistem menggunakan pendekatan Safety by Design. "
     "Distribusi implementasi nyata empat pilar Responsible AI dirangkum pada Tabel 3.", False, False)
])

# ── Tabel 3: Pilar Responsible AI dengan Kolom NO ──
build_simple_table(doc,
    ["No.", "Pilar Responsible AI", "Implementasi Nyata dan Mitigasi Risiko"],
    [
        ("1",
         "Privasi & Keamanan",
         "Pemburaman wajah dan plat nomor kendaraan diproses langsung di RAM server sebelum disimpan. Token JWT membatasi akses data antara warga dan administrator."),
        
        ("2",
         "Transparansi & Rujukan",
         "Setiap hasil analisis AI disertai skor keyakinan (confidence score). Chatbot regulasi menyertakan kutipan pasal resmi untuk menghindari kesalahan informasi hukum."),
        
        ("3",
         "Peran Manusia (HITL)",
         "AI hanya sebagai asisten pemberi rekomendasi (Human-in-the-Loop). Laporan dengan skor keyakinan di bawah 85% divalidasi oleh petugas Dinas Lingkungan Hidup secara manual sebelum disetujui."),
        
        ("4",
         "Keandalan Sistem",
         "Rate limiting membatasi frekuensi kueri chat untuk mencegah beban berlebih. Input teks melalui chatbot divalidasi menggunakan sanitasi masukan (input sanitization) dan deteksi pola prompt injection sebelum diteruskan ke model AI.")
    ],
    [1.0, 3.5, 9.5] # Total: 14.0 cm
)
add_caption(doc, "Tabel 3. Matriks implementasi pilar Responsible AI Genesis.")

# ── Paragraf Penutup: Risiko dan Peran Manusia ──
add_paragraph(doc, [
    ("Genesis memitigasi risiko bias klasifikasi (verifikasi manual), misinformasi regulasi (pembatasan basis data RAG), dan prompt injection (sanitasi input). "
     "Dengan demikian, AI berfungsi sebagai sistem pendukung keputusan (decision support system), sedangkan seluruh keputusan publik tetap berada pada kewenangan "
     "petugas Dinas Lingkungan Hidup sebagai pengambil keputusan akhir. Pendekatan ini memastikan AI berperan sebagai alat bantu analisis, bukan pengganti pertimbangan manusia.", False, False)
], space_after=Pt(0))

# ══════════════════════════════════════════════════════════════
# SIMPAN
# ══════════════════════════════════════════════════════════════
doc.save(OUTPUT)
print(f"OK: {OUTPUT}")
print(f"Size: {os.path.getsize(OUTPUT)/1024:.1f} KB")
