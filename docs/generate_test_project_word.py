"""
Generator Word Document — WorldSkills / LKS Test Project Proposal (Premium Version)
Kecerdasan Artifisial (Artificial Intelligence) LKS Nasional 2026
"""
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
import os

OUTPUT = r"d:\PROJECT ARIEF\LKS Dikdasmen\docs\Test_Project_AI_Genesis.docx"

# Konstanta Format Dokumen
FONT_NAME = "Arial"
SIZE_TITLE = Pt(22)
SIZE_H1 = Pt(14)
SIZE_H2 = Pt(12)
SIZE_BODY = Pt(10.5)
SIZE_TABLE_TEXT = Pt(9.5)
LINE_SPACING_BODY = 1.15
LINE_SPACING_TABLE = 1.05

COLOR_BLACK = RGBColor(0x00, 0x00, 0x00)
COLOR_GRAY = RGBColor(0x55, 0x55, 0x55)
COLOR_WS_BLUE = RGBColor(0x0A, 0x22, 0x40) # Warna biru tua WorldSkills

HEX_BORDER = "CCCCCC"
HEX_HEADER_BG = "F2F2F2"

def style_cell(cell, top_padding=100, bottom_padding=100, left_padding=120, right_padding=120, 
               shading_color=None, border_color=HEX_BORDER, v_align="center"):
    """Mengatur padding internal sel, shading, border grid tipis, dan perataan vertikal."""
    tcPr = cell._tc.get_or_add_tcPr()
    
    # 1. Padding Sel
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
    
    # 4. Perataan Vertikal Tengah
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
    
    words = text.split(" ")
    for word in words:
        run = p.add_run(word + " ")
        run.font.name = FONT_NAME
        run.font.size = SIZE_TABLE_TEXT
        run.font.color.rgb = COLOR_BLACK
        run.bold = bold
        
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

def add_heading_1(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pf = p.paragraph_format
    pf.space_before = Pt(18)
    pf.space_after = Pt(6)
    pf.line_spacing = 1.15
    pf.keep_with_next = True
    
    run = p.add_run(text)
    run.font.name = FONT_NAME
    run.font.size = SIZE_H1
    run.font.color.rgb = COLOR_WS_BLUE
    run.bold = True
    return p

def add_heading_2(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pf = p.paragraph_format
    pf.space_before = Pt(12)
    pf.space_after = Pt(4)
    pf.line_spacing = 1.15
    pf.keep_with_next = True
    
    run = p.add_run(text)
    run.font.name = FONT_NAME
    run.font.size = SIZE_H2
    run.font.color.rgb = COLOR_BLACK
    run.bold = True
    return p

def add_paragraph(doc, text_segments, space_after=Pt(6)):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    pf = p.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = space_after
    pf.line_spacing = LINE_SPACING_BODY
    
    for txt, b, i in text_segments:
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
    run.font.size = Pt(9.0)
    run.font.color.rgb = COLOR_GRAY
    run.italic = True

def build_simple_table(doc, headers, data, col_widths):
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
            bold = (col_idx == 0)
            align = WD_ALIGN_PARAGRAPH.CENTER if col_idx == 0 else WD_ALIGN_PARAGRAPH.LEFT
            write_cell(cell, val, bold=bold, align=align)
            style_cell(cell)
                
    # Atur Lebar Kolom (Total 15.5 cm agar pas dengan margin 3.0-2.5)
    for row in tbl.rows:
        for col_idx, width in enumerate(col_widths):
            row.cells[col_idx].width = Cm(width)
            
    return tbl

# ══════════════════════════════════════════════════════════════
# DOKUMEN SETUP (Margin WorldSkills/LKS: Left 3cm, Right 2.5cm)
# ══════════════════════════════════════════════════════════════
doc = Document()
sec = doc.sections[0]
sec.page_width = Cm(21.0)
sec.page_height = Cm(29.7)
sec.top_margin = Cm(2.5)
sec.bottom_margin = Cm(2.5)
sec.left_margin = Cm(3.0)
sec.right_margin = Cm(2.5)

# ── Konfigurasi Header dan Footer Premium ──
header = sec.header
p_header = header.paragraphs[0]
p_header.text = ""
p_header.alignment = WD_ALIGN_PARAGRAPH.RIGHT
h_run = p_header.add_run("LKS Nasional 2026 | Kecerdasan Artifisial (Artificial Intelligence)")
h_run.font.name = FONT_NAME
h_run.font.size = Pt(8.5)
h_run.font.color.rgb = COLOR_GRAY

footer = sec.footer
p_footer = footer.paragraphs[0]
p_footer.text = ""
p_footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
f_run = p_footer.add_run("Date: 05.07.2026  |  Version: 1.0  |  LKS2026_TP_AI_EN  |  © WorldSkills International")
f_run.font.name = FONT_NAME
f_run.font.size = Pt(8.5)
f_run.font.color.rgb = COLOR_GRAY


# ── Halaman Judul Formal (Cover Page Style) ──
p_space = doc.add_paragraph()
p_space.paragraph_format.space_before = Pt(36)

p_title = doc.add_paragraph()
p_title.alignment = WD_ALIGN_PARAGRAPH.LEFT
p_title_format = p_title.paragraph_format
p_title_format.space_after = Pt(12)

run_lks = p_title.add_run("LOMBA KOMPETENSI SISWA (LKS) PENDIDIKAN MENENGAH\nTINGKAT NASIONAL XXXIV TAHUN 2026\n\n")
run_lks.font.name = FONT_NAME
run_lks.font.size = Pt(13)
run_lks.font.color.rgb = COLOR_GRAY
run_lks.bold = True

run_main_title = p_title.add_run("TEST PROJECT PROPOSAL\nKecerdasan Artifisial (Artificial Intelligence)\n")
run_main_title.font.name = FONT_NAME
run_main_title.font.size = SIZE_TITLE
run_main_title.font.color.rgb = COLOR_WS_BLUE
run_main_title.bold = True

p_desc = doc.add_paragraph()
p_desc_format = p_desc.paragraph_format
p_desc_format.space_after = Pt(48)
run_desc = p_desc.add_run(
    "Nama Proyek Uji: Genesis — Platform Pelaporan Lingkungan Cerdas Berbasis Crowdsourcing, "
    "Deteksi Spasial Anti-Spam, Sensor Gambar Privasi (PII), dan Asisten Regulasi Hukum RAG dengan Model Routing\n"
)
run_desc.font.name = FONT_NAME
run_desc.font.size = Pt(11)
run_desc.italic = True
run_desc.font.color.rgb = COLOR_GRAY

# Page Break after Cover Elements
doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# CONTENTS
# ══════════════════════════════════════════════════════════════
add_heading_1(doc, "Contents")
add_paragraph(doc, [
    ("Dokumen Test Project Proposal ini terbagi atas beberapa bagian wajib sesuai ketentuan WorldSkills International:\n", False, False),
    ("1. Introduction\n", True, False),
    ("   - Memuat latar belakang masalah ekologi, visi solusi platform Genesis, dan bagan perutean model kecerdasan artifisial.\n", False, False),
    ("2. Description of project and tasks\n", True, False),
    ("   - Memuat pembagian modul kerja kompetitor (Modul A hingga Modul D) beserta deliverables teknis yang diharapkan.\n", False, False),
    ("3. Instructions to the Competitor\n", True, False),
    ("   - Panduan implementasi teknis langkah demi langkah, struktur repositori, spesifikasi basis data, dan batasan operasional.\n", False, False),
    ("4. Other\n", True, False),
    ("   - Menjabarkan kerangka kerja Responsible AI, manajemen mitigasi risiko, batasan data privasi, dan matriks penilaian LKS Nasional.", False, False),
], space_after=Pt(12))

# ══════════════════════════════════════════════════════════════
# INTRODUCTION
# ══════════════════════════════════════════════════════════════
add_heading_1(doc, "Introduction")
add_paragraph(doc, [
    ("Kerusakan akibat perubahan iklim yang kompleks di Indonesia memerlukan sistem pengambilan keputusan adaptif berbasis bukti. "
     "Banyak platform pelaporan lingkungan konvensional saat ini mengalami kegagalan adopsi karena tidak menyediakan insentif nyata bagi warga "
     "serta menyimpan laporan sebagai entitas terisolasi yang tidak saling terhubung. Informasi yang masuk terbiarkan menumpuk tanpa "
     "menjadi landasan pembentukan pengetahuan baru. Akibatnya, setiap permasalahan diperlakukan sebagai kasus terpisah tanpa akumulasi pembelajaran.\n\n"
     "Genesis hadir sebagai platform aksi iklim lokal berbasis crowdsourcing untuk menjawab tantangan tersebut dengan mengintegrasikan "
     "aplikasi mobile warga (Flutter BLoC), dasbor admin (Next.js), dan server backend (NestJS Fastify) pada infrastruktur Google Cloud Platform (GCP). "
     "Sistem ini menerapkan validasi otomatis anti-spam geospasial, penyaringan data sensitif (PII redaction) otomatis, serta asisten hukum regulasi "
     "lingkungan hidup berbasis Retrieval-Augmented Generation (RAG). Selama proses pengembangan, tim memanfaatkan ", False, False),
    ("Google Antigravity sebagai AI coding assistant", True, False),
     (" untuk penyusunan dokumentasi teknis dan optimasi kode, sementara perancangan arsitektur, implementasi fitur, validasi, dan pengujian sistem dilakukan secara mandiri oleh tim.\n\n"
      "Untuk mengoptimalkan efisiensi biaya operasional dan kecepatan respons sistem (latensi), backend Genesis menerapkan pola ", False, False),
    ("Dynamic Model Routing (Perutean Model Dinamis)", True, False),
     (" menggunakan Vertex AI. Kueri percakapan sederhana chatbot atau sapaan ringan ditangani oleh model berbiaya rendah dan latensi ultra-rendah yaitu ", False, False),
    ("Gemini 2.5 Flash Lite", True, False),
     (". Sebaliknya, kueri kompleks yang membutuhkan analisis regulasi hukum panjang, dokumen pembanding RAG, atau klasifikasi otomatis foto sampah "
      "menjadi metadata JSON diarahkan ke model dengan kemampuan penalaran tinggi yaitu ", False, False),
    ("Gemini 3.5 Flash", True, False),
     (". Hal ini memastikan sistem berjalan secara efisien, responsif, dan berorientasi pada dampak nyata aksi iklim lokal.", False, False)
])

# ══════════════════════════════════════════════════════════════
# DESCRIPTION OF PROJECT AND TASKS
# ══════════════════════════════════════════════════════════════
add_heading_1(doc, "Description of project and tasks")
add_paragraph(doc, [
    ("Proyek uji ini dirancang untuk menguji kompetensi holistik peserta dalam bidang Kecerdasan Artifisial. "
     "Peserta diwajibkan menyelesaikan seluruh milestones yang dibagi ke dalam 4 modul deliverables:", False, False),
])

add_heading_2(doc, "Module A: Mobile Client & UI Gamifikasi (Flutter)")
add_paragraph(doc, [
    ("Kompetitor harus membangun antarmuka mobile warga menggunakan Flutter dengan arsitektur bersih dan manajemen status BLoC. "
     "Deliverables wajib meliputi: (1) Halaman pelaporan sampah yang mengambil foto kamera dan melampirkan metadata koordinat GPS secara otomatis via geolocator; "
     "(2) Tampilan gamifikasi interaktif yang menyajikan data poin pengalaman (XP), akumulasi level warga, lencana (badges), dan papan peringkat (leaderboard) secara real-time.", False, False),
])

add_heading_2(doc, "Module B: Backend API & Integrasi Database (NestJS + Supabase)")
add_paragraph(doc, [
    ("Kompetitor harus mengimplementasikan API RESTful menggunakan NestJS Fastify. "
     "Deliverables wajib meliputi: (1) Endpoint autentikasi dan pendaftaran berbasis JWT token; "
     "(2) Skema otorisasi berbasis peran (RBAC) untuk membedakan rute menu warga (citizen) dan menu pengelola (admin); "
     "(3) Integrasi Supabase PostgreSQL sebagai pusat penyimpanan data relasional.", False, False),
])

add_heading_2(doc, "Module C: Deteksi Spasial Anti-Spam & Sensor Gambar Privasi (PII)")
add_paragraph(doc, [
    ("Kompetitor mengonfigurasikan modul keamanan data dan sanitasi laporan. "
     "Deliverables wajib meliputi: (1) Fungsi database PostGIS ", False, False),
    ("check_duplicate_report()", False, True),
    (" untuk membandingkan koordinat laporan baru dengan laporan aktif dalam radius 50 meter dan rentang waktu 12 jam guna mencegah duplikasi data; "
     "(2) Sensor gambar otomatis berbasis Google Vision API untuk mendeteksi koordinat bounding box wajah manusia dan plat nomor kendaraan; "
     "(3) Modul Sharp untuk menerapkan Gaussian Blur destruktif secara in-memory sebelum buffer gambar diunggah ke Google Cloud Storage (GCS).", False, False),
])

add_heading_2(doc, "Module D: RAG Chatbot & Dynamic Model Routing")
add_paragraph(doc, [
    ("Kompetitor merancang asisten hukum regulasi lingkungan hidup menggunakan pgvector dan Gemini Embedding. "
     "Deliverables wajib meliputi: (1) Pencarian kesamaan kosinus pada indeks vektor HNSW untuk mencari pasal hukum yang relevan; "
     "(2) Modul transkripsi suara warga berbasis Whisper-1; "
     "(3) Pengontrol perutean model AI (Model Router) yang secara dinamis mengalihkan kueri pendek ke Gemini 2.5 Flash Lite dan kueri analisis dokumen ke Gemini 3.5 Flash; "
     "(4) Respons streaming data menggunakan Server-Sent Events (SSE).", False, False),
])

# Page Break for Instructions Section
doc.add_page_break()

# ══════════════════════════════════════════════════════════════
# INSTRUCTIONS TO THE COMPETITOR
# ══════════════════════════════════════════════════════════════
add_heading_1(doc, "Instructions to the Competitor")
add_paragraph(doc, [
    ("Berikut adalah instruksi pengerjaan teknis rinci yang wajib diikuti oleh kompetitor untuk menyelesaikan setiap modul:", False, False),
])

# ── Tabel 1: Instruksi Modul Kompetitor ──
build_simple_table(doc,
    ["Modul", "Instruksi Kerja & Spesifikasi Teknis", "Kriteria Evaluasi & Keberhasilan"],
    [
        ("Modul A",
         "1. Konfigurasikan Geolocator Flutter untuk mengambil data garis lintang/bujur.\n2. Terapkan state management BLoC untuk melacak riwayat laporan dan data XP gamifikasi.\n3. Rancang tampilan leaderboard dan badges menggunakan custom UI widget.",
         "Aplikasi berhasil menangkap GPS perangkat secara background saat kamera aktif, dan menampilkan riwayat poin dengan state BLoC yang stabil."),
        
        ("Modul B",
         "1. Buat REST controller NestJS menggunakan adapter Fastify.\n2. Hubungkan service ke database PostgreSQL Supabase.\n3. Implementasikan AuthGuard menggunakan Passport JWT dan RolesGuard berbasis metadata role.",
         "API merespons request dalam <150ms. Request tanpa Authorization header Bearer token ditolak dengan HTTP Status 401 Unauthorized."),
        
        ("Modul C",
         "1. Tulis stored procedure SQL PostGIS menggunakan fungsi ST_DWithin untuk perbandingan jarak spasial.\n2. Kirim gambar ke Google Vision API, deteksi bounding box wajah/plat nomor.\n3. Olah buffer gambar menggunakan Sharp langsung di memori server.",
         "Fungsi check_duplicate_report() mendeteksi spam dengan tepat. Gambar tersimpan di GCS terbukti telah tersensor pada wajah/plat nomor."),
        
        ("Modul D",
         "1. Konfigurasikan tabel pgvector Supabase dengan embedding 768 dimensi.\n2. Buat fungsi Model Router yang memeriksa panjang karakter input (kueri < 100 karakter diarahkan ke Gemini 2.5 Flash Lite, kueri >= 100 karakter atau pencarian dokumen diarahkan ke Gemini 3.5 Flash).\n3. Kirimkan transkripsi suara M4A via Whisper-1 dan streaming SSE.",
         "Sistem merespons kueri sapaan singkat secara instan (<500ms). Kueri regulasi menampilkan kutipan pasal hukum resmi secara streaming.")
    ],
    [2.0, 7.5, 6.0] # Total: 15.5 cm
)
add_caption(doc, "Tabel 1. Panduan instruksi kerja teknis dan kriteria keberhasilan bagi kompetitor LKS.")

# ══════════════════════════════════════════════════════════════
# OTHER
# ══════════════════════════════════════════════════════════════
add_heading_1(doc, "Other")

add_heading_2(doc, "1. Penerapan Responsible AI dan Mitigasi Risiko")
add_paragraph(doc, [
    ("Proyek uji ini sangat menekankan pentingnya etika AI dan perlindungan privasi data. "
     "Kompetitor wajib membuktikan penerapan prinsip-prinsip kecerdasan artifisial yang bertanggung jawab melalui langkah konkret:\n"
     "- Privasi (PII Redaction): Sensor wajah dan plat nomor diproses secara in-memory (RAM server) sehingga tidak ada file mentah tanpa blur yang tersimpan di cloud storage.\n"
     "- Mitigasi Misinformasi (RAG Grounding): Jawaban chatbot dibatasi hanya bersumber dari database regulasi undang-undang lingkungan hidup resmi guna mencegah halusinasi LLM.\n"
     "- Mitigasi Keamanan (Prompt Injection Guardrails): Backend mendeteksi dan menolak pola prompt injection atau evasion sebelum input diteruskan ke model LLM.\n"
     "- Peran Penilaian Manusia (Human-in-the-Loop): AI diposisikan sebagai asisten pendukung keputusan (decision support system). Laporan dengan skor keyakinan AI di bawah 85% akan berstatus \"pending_human\" dan wajib divalidasi manual oleh petugas Dinas Lingkungan Hidup melalui dasbor Next.js sebelum dirilis ke publik.", False, False),
])

add_heading_2(doc, "2. Batasan Data & Sumber Data")
add_paragraph(doc, [
    ("Seluruh pengerjaan hanya diperbolehkan menggunakan data yang aman dan terbebas dari Pelanggaran Informasi Identitas Pribadi (PII):\n"
     "1. Data Partisipasi Publik: Dataset koordinat dan foto uji coba lingkungan hasil simulasi perangkat pengembang.\n"
     "2. Data Regulasi Daerah: Dokumen peraturan perundang-undang resmi daerah dan nasional tentang pengelolaan lingkungan hidup.\n"
     "3. Data Historis: Data relasional PostgreSQL yang memuat profil samaran username warga dan perolehan poin gamifikasi.", False, False),
])

add_heading_2(doc, "3. Rubrik Penilaian Kompetisi")
add_paragraph(doc, [
    ("Penilaian performa hasil kerja kompetitor oleh juri nasional didistribusikan secara transparan berdasarkan matriks penilaian pada Tabel 2.", False, False),
])

# ── Tabel Rubrik Penilaian Proyek ──
build_simple_table(doc,
    ["No.", "Kriteria Evaluasi Juri", "Bobot", "Metode Pengujian & Aspek Penilaian"],
    [
        ("1", "Pemahaman masalah & relevansi case", "20%", "Ketepatan solusi dalam menyelesaikan geospasial spam dan kebutuhan aksi iklim lokal."),
        ("2", "Kreativitas & inovasi solusi", "20%", "Keunikan integrasi gamifikasi, deteksi spasial PostGIS, dan model routing dinamis."),
        ("3", "Pemanfaatan AI yang efektif & berdampak", "20%", "Keberhasilan klasifikasi citra Gemini 3.5 Flash dan performa pencarian dokumen RAG."),
        ("4", "Penerapan Responsible AI (HITL & PII)", "15%", "Keandalan modul sensor Sharp dan validasi manual status pending_human di dasbor."),
        ("5", "Fungsionalitas aplikasi/prototipe", "15%", "Kemudahan instalasi Flutter mobile client, kestabilan REST API, dan integrasi admin dashboard."),
        ("6", "Kejelasan presentasi & dokumentasi", "10%", "Kerapian struktur kode (clean code), dokumentasi teknis, dan kejelasan video presentasi.")
    ],
    [1.0, 5.5, 1.5, 7.5] # Total: 15.5 cm
)
add_caption(doc, "Tabel 2. Rubrik penilaian penentuan pemenang kompetisi AI LKS Nasional 2026.")

# ══════════════════════════════════════════════════════════════
# SIMPAN DOKUMEN
# ══════════════════════════════════════════════════════════════
doc.save(OUTPUT)
print(f"OK: {OUTPUT}")
print(f"Size: {os.path.getsize(OUTPUT)/1024:.1f} KB")
