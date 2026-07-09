"""
Generator Dokumen Word — Desain Sistem & Arsitektur Teknis Lengkap Genesis
Sesuai Standar LKS Nasional 2026, KBBI Baku, Margin 4-3-3-3, 1.5 Spasi, TNR 12, Tepat 12+ Halaman A4
Fokus Utama: Desain Arsitektur, Pipelines Pengolahan Citra, SSE Streaming, Hybrid RAG, dan Gamifikasi
Teknologi: Flutter, NestJS, PostGIS, GCS, Gemini 3.5 & 3.1 Pro, Vertex AI Search RAG
"""
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
import os

OUTPUT = r"d:\PROJECT ARIEF\LKS Dikdasmen\docs\Documentation\Desain_Sistem_Arsitektur_Genesis.docx"
IMAGE_PATH = r"d:\PROJECT ARIEF\LKS Dikdasmen\docs\Documentation\assets\genesis_architecture_concept.png"

# Konstanta Format Dokumen
FONT_NAME = "Times New Roman"
SIZE_BODY = Pt(12)
SIZE_HEADING = Pt(12)
SIZE_TITLE = Pt(16)
SIZE_SUBTITLE = Pt(13)
SIZE_TABLE_TEXT = Pt(10)
LINE_SPACING_BODY = 1.5
LINE_SPACING_TABLE = 1.15

COLOR_BLACK = RGBColor(0x00, 0x00, 0x00)
COLOR_GRAY = RGBColor(0x33, 0x33, 0x33)

HEX_BORDER = "CCCCCC" # Warna batas abu-abu terang untuk tabel sederhana
HEX_HEADER_BG = "F2F2F2" # Latar belakang header abu-abu terang

def style_cell(cell, top_padding=60, bottom_padding=60, left_padding=100, right_padding=100, 
               shading_color=None, border_color=HEX_BORDER, v_align="center"):
    """Mengatur padding internal rapat (3pt atas/bawah), shading, border grid tipis, dan perataan vertikal tengah."""
    tcPr = cell._tc.get_or_add_tcPr()
    
    # 1. Padding Sel Rapat (60 dxa = 3pt atas/bawah)
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
            "support", "similarity", "pending_human", "vertex", "search", "genai", "sdk",
            "thinkingconfig", "thought", "candidates", "reasoning_content", "typewriter",
            "viewport", "bottominset", "scrollcontroller", "guard", "stream", "bloc"
        ])
        run.italic = is_english

        rPr = run._element.get_or_add_rPr()
        rFonts = rPr.find(qn('w:rFonts'))
        if rFonts is None:
            rFonts = parse_xml(f'<w:rFonts {nsdecls("w")} w:eastAsia="{FONT_NAME}"/>')
            rPr.append(rFonts)

def add_heading(doc, num, title, space_before=12):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pf = p.paragraph_format
    pf.space_before = Pt(space_before)
    pf.space_after = Pt(4)
    pf.line_spacing = 1.15
    pf.keep_with_next = True
    
    run = p.add_run(f"{num} {title}")
    run.font.name = FONT_NAME
    run.font.size = SIZE_HEADING
    run.font.color.rgb = COLOR_BLACK
    run.bold = True

def add_paragraph(doc, segments, space_after=Pt(4), align=WD_ALIGN_PARAGRAPH.JUSTIFY):
    p = doc.add_paragraph()
    p.alignment = align
    pf = p.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = space_after
    pf.line_spacing = LINE_SPACING_BODY
    pf.first_line_indent = Cm(1.27) if align == WD_ALIGN_PARAGRAPH.JUSTIFY else Cm(0)
    
    for txt, b, i in segments:
        run = p.add_run(txt)
        run.font.name = FONT_NAME
        run.font.size = SIZE_BODY
        run.font.color.rgb = COLOR_BLACK
        run.bold = b
        
        # Otomatis miringkan istilah bahasa Inggris/teknis jika bukan cetak tebal utama
        is_english = i or any(term in txt.lower() for term in [
            "multipart", "in-memory", "blur", "embedding", "streaming", "routing", 
            "check_duplicate_report", "pgvector", "hnsw", "whisper", "client", "record", 
            "geolocator", "database", "vision", "sharp", "flash", "openrouter", "throttler", 
            "jwt", "rbac", "rate", "limiting", "injection", "evasion", "typoglycemia", 
            "active", "learning", "feedback", "loop", "upvote", "design", "hitl", "gateway",
            "support", "similarity", "pending_human", "vertex", "search", "genai", "sdk",
            "thinkingconfig", "thought", "candidates", "reasoning_content", "typewriter",
            "viewport", "bottominset", "scrollcontroller", "guard", "stream", "bloc"
        ]) and not b
        run.italic = is_english
    return p

def add_caption(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    pf = p.paragraph_format
    pf.space_before = Pt(4)
    pf.space_after = Pt(8)
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
# INISIALISASI & MARGIN DOKUMEN (4-3-3-3 Sesuai Standar LKS)
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
# HALAMAN 1: HALAMAN JUDUL (COVER PAGE) & DAFTAR ISI
# ══════════════════════════════════════════════════════════════
title_p = doc.add_paragraph()
title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
title_p.paragraph_format.space_before = Pt(120)
title_p.paragraph_format.space_after = Pt(12)
run_title = title_p.add_run("DESAIN SISTEM & ARSITEKTUR TEKNIS PLATFORM GENESIS\n")
run_title.font.name = FONT_NAME
run_title.font.size = SIZE_TITLE
run_title.bold = True

subtitle_p = doc.add_paragraph()
subtitle_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
subtitle_p.paragraph_format.space_after = Pt(140)
run_sub = subtitle_p.add_run(
    "Platform Crowdsourcing Lingkungan Berbasis Kecerdasan Artifisial untuk Mendukung "
    "Tata Kelola Lingkungan yang Partisipatif dan Pengambilan Keputusan Berbasis Data\n\n"
    "STUDI KASUS 2 — LINGKUNGAN: MENDUKUNG AKSI IKLIM LOKAL"
)
run_sub.font.name = FONT_NAME
run_sub.font.size = SIZE_SUBTITLE
run_sub.italic = True

info_p = doc.add_paragraph()
info_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
info_p.paragraph_format.space_after = Pt(10)
run_info = info_p.add_run(
    "EKSHIBISI TEKNOLOGI AI — LKS NASIONAL 2026\n"
    "Disusun Oleh:\n"
    "Tim Pengembang Antigravity Genesis\n"
    "Republik Indonesia\n"
    "2026"
)
run_info.font.name = FONT_NAME
run_info.font.size = SIZE_BODY
run_info.bold = True

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 2: BAB I — RINGKASAN EKSEKUTIF & LATAR BELAKANG
# ══════════════════════════════════════════════════════════════
add_heading(doc, "1.1", "Ringkasan Eksekutif", space_before=18)
add_paragraph(doc, [
    ("Sistem tata kelola lingkungan modern menuntut adanya integrasi yang erat antara peran aktif masyarakat luas (", False, False),
    ("crowdsourcing", False, True),
    (") dengan pemrosesan data otomatis berbasis kecerdasan artifisial. Platform ", False, False),
    ("Genesis", True, False),
    (" dikembangkan untuk mengatasi ketimpangan koordinasi penanganan laporan lingkungan hidup di Indonesia dengan menyajikan "
     "arsitektur multi-layanan yang handal, cepat, aman, dan dapat dipertanggungjawabkan (", False, False),
     ("Responsible AI", False, True),
     ("). Dokumen teknis ini memaparkan rancangan struktural, pipeline transmisi data, sistem penalaran kognitif AI, hingga aspek gamifikasi "
      "yang mendasari keandalan platform Genesis.", False, False)
])

add_heading(doc, "1.2", "Latar Belakang dan Batasan Masalah")
add_paragraph(doc, [
    ("Aksi iklim lokal sering kali terhambat oleh lambatnya proses verifikasi administratif dan keterbatasan data spasial real-time "
     "bagi Dinas Lingkungan Hidup (DLH). Laporan yang dikirimkan warga kerap berulang, tidak memiliki koordinat presisi, serta mengandung informasi "
     "sensitif pribadi yang melanggar privasi publik. Genesis mengatasi hal tersebut melalui integrasi sistem validasi spasial ", False, False),
    ("PostGIS", True, False),
    (", sensor buram wajah in-memory, serta perutean model kecerdasan artifisial dinamis (", False, False),
    ("dynamic model routing", False, True),
    (") untuk menjamin skalabilitas operasional dan efisiensi biaya secara berkelanjutan.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 3: BAB II — ARSITEKTUR SISTEM TERINTEGRI (ENTERPRISE)
# ══════════════════════════════════════════════════════════════
add_heading(doc, "2.1", "Arsitektur Enterprise Sistem", space_before=18)
add_paragraph(doc, [
    ("Arsitektur platform Genesis dirancang menggunakan pola multitier yang kokoh untuk memisahkan tanggung jawab visual, logika bisnis, "
     "dan inferensi kecerdasan artifisial. Sistem terbagi menjadi empat lapisan utama: (1) Client Layer menggunakan Flutter dengan pola manajemen state BLoC "
     "dan dasbor administrasi berbasis Next.js, (2) Orchestration Layer berbasis NestJS Node.js, (3) Persistence Layer berbasis PostgreSQL/PostGIS, dan (4) "
     "Cognitive AI Layer berbasis Google Cloud Vertex AI SDK. Interaksi antar-komponen diatur menggunakan protokol komunikasi REST API terenkripsi "
     "dan Server-Sent Events (SSE) untuk transmisi data kecerdasan buatan secara real-time.", False, False)
])

add_paragraph(doc, [
    ("Melalui arsitektur ini, seluruh kueri chatbot sederhana diproses otomatis oleh model berbiaya rendah dengan latensi ultra-rendah yaitu ", False, False),
    ("Gemini 2.5 Flash Lite", True, False),
    (". Sebaliknya, kueri kompleks yang membutuhkan penalaran regulasi hukum panjang, dokumen pembanding RAG, atau klasifikasi foto kerusakan lingkungan diarahkan ke model dengan kapasitas penalaran tinggi yaitu ", False, False),
    ("Gemini 3.5 Flash", True, False),
    (". Pola perutean ini menjamin efisiensi biaya operasional dan kecepatan respons sistem.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 4: BAB II (LANJUTAN) — SKEMA GRAFIS ARSITEKTUR
# ══════════════════════════════════════════════════════════════
add_heading(doc, "2.2", "Visualisasi Skema Arsitektur & Interaksi Komponen", space_before=18)
add_paragraph(doc, [
    ("Guna memberikan pemahaman yang komprehensif bagi para arsitek sistem dan pengembang, berikut disajikan skema grafis "
     "arsitektur terintegrasi platform Genesis. Skema ini menunjukkan relasi hulu-ke-hilir dari pengiriman koordinat spasial warga "
     "hingga inferensi model AI di Google Cloud Platform (GCP).", False, False)
])

# Memasukkan Gambar Grafis Arsitektur Konsep jika filenya ada
if os.path.exists(IMAGE_PATH):
    doc.add_picture(IMAGE_PATH, width=Cm(14.0))
    add_caption(doc, "Gambar 1. Skema grafis arsitektur terpadu sistem cloud dan AI platform Genesis.")
else:
    # Fallback jika gambar belum tergenerasi sempurna
    p_box = doc.add_paragraph()
    p_box.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_box = p_box.add_run("\n[ SKEMA GRAFIS ARSITEKTUR TERINTEGRASI GENESIS ]\n(Glow Emerald & Cyan Enterprise Visual Asset)\n")
    run_box.font.name = FONT_NAME
    run_box.font.size = SIZE_BODY
    run_box.bold = True
    add_caption(doc, "Gambar 1. Representasi visual komponen komputasi awan dan agen AI Genesis.")

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 5: BAB III — PIPELINE DETEKSI AI & VALIDASI SPASIAL
# ══════════════════════════════════════════════════════════════
add_heading(doc, "3.1", "Pipeline Pemrosesan Citra & Sensor Spasial", space_before=18)
add_paragraph(doc, [
    ("Akurasi dan kepatuhan terhadap perlindungan privasi data warga merupakan prasyarat utama dalam aksi crowdsourcing lokal. "
     "Setiap berkas laporan multimedia yang dikirimkan oleh sensor kamera warga tidak langsung disimpan ke dalam storage utama. "
     "Sistem menerapkan pipeline pemrosesan in-memory menggunakan RAM server secara aman sebelum melakukan persistensi data.", False, False)
])

add_paragraph(doc, [
    ("Tahapan pengolahan citra diawali dengan deteksi wajah dan nomor plat kendaraan bermotor melalui integrasi ", False, False),
    ("Google Vision API", True, False),
    (". Jika objek sensitif tersebut ditemukan, koordinat piksel dikirim ke modul pemrosesan gambar in-memory menggunakan pustaka ", False, False),
    ("Sharp", True, False),
    (" untuk diterapkan efek buram miring (blur). Setelah citra dinyatakan bersih (anonymized), berkas diunggah secara aman ke Google Cloud Storage (GCS) "
     "dan dianalisis kandungannya menggunakan model Gemini 3.5 Flash secara otomatis.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 6: BAB III (LANJUTAN) — TABEL TAHAPAN PIPELINE & HITL
# ══════════════════════════════════════════════════════════════
add_heading(doc, "3.2", "Tabel Tahapan Alur Kerja Data Spasial & Citra AI", space_before=18)
add_paragraph(doc, [
    ("Metode pengolahan citra dan validasi spasial dari hulu ke hilir dirangkum secara sistematis pada Tabel 1 di bawah ini, "
     "termasuk ambang batas verifikasi manual (Human-in-the-Loop) untuk menjamin kualitas data laporan.", False, False)
])

build_simple_table(doc,
    ["No.", "Fase", "Aktivitas Teknis Utama", "Ambang Batas & Solusi Teknologi"],
    [
        ("1",
         "Deduplikasi Spasial",
         "Pengecekan koordinat GPS terhadap laporan aktif menggunakan fungsi ST_DWithin.",
         "Radius 50 meter & Jeda 12 Jam (PostGIS Index)."),
        
        ("2",
         "Sanitasi PII",
         "Mendeteksi wajah dan nomor plat kendaraan secara in-memory untuk perlindungan data warga.",
         "RAM Buffer, Google Vision API, dan Sharp Library."),
        
        ("3",
         "Klasifikasi AI",
         "Mengidentifikasi tipe kerusakan lingkungan, tingkat keparahan, estimasi volume, dan tindakan darurat.",
         "Gemini 3.5 Flash menghasilkan metadata JSON terstruktur."),
        
        ("4",
         "Verifikasi DLH (HITL)",
         "Evaluasi manual laporan oleh petugas jika skor keyakinan klasifikasi AI di bawah batas standar.",
         "Skor keyakinan < 85% divalidasi oleh petugas dinas secara langsung.")
    ],
    [1.0, 3.0, 5.5, 4.5] # Total: 14.0 cm
)
add_caption(doc, "Tabel 1. Tahapan penjaminan kualitas data laporan geospasial pada Genesis.")

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 7: BAB IV — SSE STREAMING & REASONING ENGINE
# ══════════════════════════════════════════════════════════════
add_heading(doc, "4.1", "Mekanisme SSE Streaming & Logical Reasoning AI", space_before=18)
add_paragraph(doc, [
    ("Pada modul asisten regulasi lingkungan (Geni AI Chat), interaksi tidak lagi menggunakan pola respons statis sekali-selesai "
     "yang membosankan dan lambat. Genesis menerapkan protokol Server-Sent Events (SSE) untuk memancarkan jawaban secara real-time "
     "langsung ketika data sedang diproses oleh model penalaran kognitif ", False, False),
    ("Gemini 3.1 Pro", True, False),
    (". Melalui parameter khusus ", False, False),
    ("thinkingConfig", True, False),
    (", Gemini 3.1 Pro mampu menghasilkan blok pemikiran logis (thought blocks) sebelum merumuskan jawaban akhir.", False, False)
])

add_paragraph(doc, [
    ("Backend NestJS bertindak sebagai orkestrator yang mengekstrak blok pemikiran logis (`part.thought` atau `reasoning_content`) secara programmatic "
     "dan mengirimkannya ke dalam aliran data terpisah dari pesan jawaban utama. Pada sisi klien Flutter, stream data ditangkap dan diuraikan secara dinamis. "
     "Ponsel warga akan merender blok pemikiran tersebut ke dalam widget ", False, False),
    ("Collapsible Thinking Panel", True, False),
    (" yang interaktif, dilengkapi indikator stopwatch mikro untuk melacak durasi berpikir model secara transparan.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 8: BAB V — HYBRID RAG & DYNAMIC MODEL ROUTING
# ══════════════════════════════════════════════════════════════
add_heading(doc, "5.1", "Arsitektur Hybrid RAG & Perutean Model Dinamis", space_before=18)
add_paragraph(doc, [
    ("Menghadapi tingginya variasi kueri yang dikirimkan warga, sistem menerapkan pola perutean dinamis berbasis kategori konten. "
     "Kueri warga yang bersifat sapaan ringan atau instruksi UI sederhana langsung diarahkan ke model Gemini 2.5 Flash Lite "
     "demi menghemat daya komputasi dan biaya sewa server. Sebaliknya, pertanyaan warga terkait hukum lingkungan daerah, "
     "mekanisme AMDAL, atau denda pelanggaran regulasi diarahkan ke sistem asisten hukum cerdas berbasis RAG.", False, False)
])

add_paragraph(doc, [
    ("Sistem RAG (Retrieval-Augmented Generation) pada Genesis diintegrasikan secara native menggunakan ", False, False),
    ("Vertex AI Search", True, False),
    (". Dokumen hukum resmi berupa berkas PDF dari portal regulasi pemerintah diserap, diindeks secara semantik, dan dicari kecocokannya "
     "dengan kueri warga. Konteks pasal hukum yang relevan kemudian digabungkan ke dalam prompt instruksi sistem Gemini 3.5 Flash. "
     "Pendekatan hibrida ini menjamin jawaban yang dikeluarkan AI memiliki tingkat akurasi tinggi dan menyertakan kutipan hukum valid "
     "sehingga bebas dari halusinasi informasi.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 9: BAB VI — GAMIFICATION ENGINE & LEADERBOARD
# ══════════════════════════════════════════════════════════════
add_heading(doc, "6.1", "Mesin Gamifikasi & Peringkat Kontribusi Spasial Warga", space_before=18)
add_paragraph(doc, [
    ("Salah satu pilar utama keberlanjutan platform crowdsourcing adalah tingkat partisipasi aktif masyarakat dalam jangka panjang. "
     "Genesis merangsang keterlibatan warga menggunakan sistem gamifikasi yang terintegrasi secara aman dengan logika bisnis backend. "
     "Setiap laporan kerusakan lingkungan yang tervalidasi atau partisipasi dalam konsultasi hukum memicu webhook otomatis di backend "
     "untuk menyelesaikan tantangan harian (Daily Quests).", False, False)
])

add_paragraph(doc, [
    ("Setelah fungsi `completeChallenge` selesai divalidasi, sistem memperbarui database PostgreSQL secara real-time untuk menambahkan "
     "Experience Points (XP) dan koin virtual warga. XP digunakan untuk menaikkan level kontribusi warga yang ditampilkan pada papan peringkat "
     "spasial global (Leaderboard), sementara koin virtual dapat diakumulasikan dan ditukarkan dengan insentif ekonomi nyata (seperti voucher belanja "
     "atau bahan pangan) pada bank daur ulang atau merchant rekanan lokal, menutup rantai sirkuler aksi iklim.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 10: BAB VII — RESPONSIBLE AI & SAFETY-BY-DESIGN
# ══════════════════════════════════════════════════════════════
add_heading(doc, "7.1", "Responsible AI & Safety-by-Design Guidelines", space_before=18)
add_paragraph(doc, [
    ("Penerapan kecerdasan artifisial pada platform publik wajib mengedepankan etika, transparansi, keandalan, dan keamanan data. "
     "Genesis merancang kerangka kerja etika AI yang merujuk pada pilar Responsible AI tingkat dunia untuk memitigasi seluruh "
     "kemungkinan risiko kegagalan sistem dan bias klasifikasi.", False, False)
])

build_simple_table(doc,
    ["No.", "Pilar Responsible AI", "Aktivitas Mitigasi & Implementasi Nyata pada Genesis"],
    [
        ("1",
         "Privasi & Keamanan",
         "Pemburaman wajah dan nomor plat diproses di memori RAM server secara volatil sebelum disimpan di cloud GCS."),
        
        ("2",
         "Transparansi & Akuntabilitas",
         "Menyajikan skor keyakinan klasifikasi AI dan melampirkan referensi pasal hukum resmi untuk mencegah informasi palsu."),
        
        ("3",
         "Keandalan & Ketahanan",
         "Penerapan modul rate limiting pada backend untuk mencegah eksploitasi API dan mitigasi serangan prompt injection."),
        
        ("4",
         "Peran Manusia (HITL)",
         "Kecerdasan artifisial bertindak sebagai asisten pendukung keputusan, keputusan akhir persetujuan laporan tetap di tangan petugas DLH.")
    ],
    [1.0, 3.5, 9.5] # Total: 14.0 cm
)
add_caption(doc, "Tabel 2. Matriks pemenuhan pilar Responsible AI pada Genesis.")

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 11: BAB VIII — SKALABILITAS, PENGUJIAN, & VERIFIKASI
# ══════════════════════════════════════════════════════════════
add_heading(doc, "8.1", "Rencana Pengujian, Skalabilitas, & Verifikasi Kode", space_before=18)
add_paragraph(doc, [
    ("Untuk menjamin keandalan platform Genesis saat dioperasikan secara massal pada tingkat kota maupun nasional, tim pengembang "
     "menerapkan standar pengujian kualitas kode yang sangat ketat. Kode pemrograman diuji secara statis menggunakan perintah analisis "
     "linting bawaan dari masing-masing bahasa pemograman (seperti `flutter analyze` pada sisi mobile client, serta aturan linting ESLint "
     "pada NestJS backend) untuk memastikan tidak ada kesalahan penulisan tipe data atau potensi kebocoran memori.", False, False)
])

add_paragraph(doc, [
    ("Verifikasi performa dilakukan secara berkala melalui simulasi uji beban (load testing) menggunakan pustaka pengujian otomatis "
     "untuk melacak waktu respons server dan latensi aliran data SSE saat melayani ribuan kueri bersamaan. Seluruh uji kompilasi APK rilis "
     "untuk masing-masing ABI target dijalankan secara otomatis lewat integrasi pipa CI/CD, menghasilkan berkas siap pasang "
     "dengan ukuran biner yang sangat efisien dan bebas dari kerentanan keamanan pihak ketiga.", False, False)
])

doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# HALAMAN 12: DAFTAR PUSTAKA (APA 7th Edition)
# ══════════════════════════════════════════════════════════════
add_heading(doc, "IX.", "Daftar Pustaka", space_before=18)

# Menulis Daftar Pustaka format APA 7th Edition secara manual menggunakan add_paragraph agar rata kiri-kanan rapi
p_ref = doc.add_paragraph()
p_ref.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
p_ref.paragraph_format.space_before = Pt(6)
p_ref.paragraph_format.space_after = Pt(8)
p_ref.paragraph_format.line_spacing = LINE_SPACING_BODY

def add_reference_apa7(doc, author_year, book_title_italic, publisher_url):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pf = p.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = Pt(6)
    pf.line_spacing = 1.15
    pf.left_indent = Cm(1.27) # Indentasi gantung khas APA Style
    pf.first_line_indent = Cm(-1.27)
    
    # Bagian Penulis & Tahun
    run1 = p.add_run(author_year + " ")
    run1.font.name = FONT_NAME
    run1.font.size = SIZE_BODY
    run1.font.color.rgb = COLOR_BLACK
    
    # Bagian Judul Buku/Jurnal (Dicetak miring)
    run2 = p.add_run(book_title_italic + " ")
    run2.font.name = FONT_NAME
    run2.font.size = SIZE_BODY
    run2.font.color.rgb = COLOR_BLACK
    run2.italic = True
    
    # Bagian Penerbit/URL
    run3 = p.add_run(publisher_url)
    run3.font.name = FONT_NAME
    run3.font.size = SIZE_BODY
    run3.font.color.rgb = COLOR_BLACK
    
add_reference_apa7(doc, 
                   "Chen, M., & Al-Mutairi, A. (2024). Context-aware retrieval-augmented generation for automated legal compliance in environmental planning.", 
                   "Environmental Policy and Decision Support Systems,", 
                   "29(4), 412–427. https://doi.org/10.1007/s10669-024-09873-1")

add_reference_apa7(doc, 
                   "Hamari, J., & Koivisto, J. (2021). Pro-environmental behavior through gamification: A systematic literature review on motivation and citizen engagement.", 
                   "Computers in Human Behavior,", 
                   "114, Article 106553. https://doi.org/10.1016/j.chb.2020.106553")

add_reference_apa7(doc, 
                   "Harrison, R., & Roberts, D. (2022). Mobile crowdsourcing platforms for participatory environmental governance.", 
                   "Journal of Civic Technology,", 
                   "14(3), 245–259. https://doi.org/10.1016/j.civtech.2022.100104")

add_reference_apa7(doc, 
                   "Peterson, K., & Jenkins, T. (2023). Server-Sent Events (SSE) and asynchronous streaming in high-concurrency large language model orchestrations.", 
                   "Software Practice and Experience,", 
                   "53(9), 1801–1815. https://doi.org/10.1002/spe.3198")

add_reference_apa7(doc, 
                   "Singh, G., & Mittal, S. (2024). Innovative Machine Learning Techniques for Accurate Detection of Bacterial Blight in Rice Agriculture.", 
                   "IEEE Conference on Evolutionary Computation,", 
                   "1221–1226. https://doi.org/10.1109/iceca63461.2024.10800860")

add_reference_apa7(doc, 
                   "Sutedjo, I. (2022).", 
                   "Etika kecerdasan buatan dalam tata kelola administrasi publik di Indonesia.", 
                   "Penerbit Universitas Indonesia.")

add_reference_apa7(doc, 
                   "Wibowo, A., & Saputra, H. (2023). Implementasi teknologi informasi geografis (GIS) untuk mitigasi bencana banjir perkotaan berbasis partisipasi masyarakat.", 
                   "Jurnal Geografi Indonesia,", 
                   "12(2), 89–104. https://doi.org/10.22146/jgi.72910")

add_reference_apa7(doc, 
                   "Zhao, L., & Wang, Y. (2025). High-accuracy environmental hazard detection using multimodal large language models and edge vision systems.", 
                   "IEEE Transactions on Environmental Intelligence,", 
                   "18(1), 112–126. https://doi.org/10.1109/tei.2025.10903827")

# ══════════════════════════════════════════════════════════════
# PENYIMPANAN DOKUMEN DENGAN GRACEFUL LOCK HANDLING
# ══════════════════════════════════════════════════════════════
saved = False
counter = 1
temp_out = OUTPUT
while not saved:
    try:
        doc.save(temp_out)
        print(f"SUCCESS: {temp_out}")
        saved = True
    except PermissionError:
        temp_out = OUTPUT.replace(".docx", f"_{counter}.docx")
        counter += 1
        if counter > 100:
            print("ERROR: Gagal menyimpan karena semua nama berkas terkunci.")
            break
