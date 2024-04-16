using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mhi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Drzava",
                columns: table => new
                {
                    DrzavaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_drzave = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_drzava", x => x.DrzavaID);
                });

            migrationBuilder.CreateTable(
                name: "Izvjestaj",
                columns: table => new
                {
                    IzvjestajID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_izvjestaj", x => x.IzvjestajID);
                });

            migrationBuilder.CreateTable(
                name: "Kategorija",
                columns: table => new
                {
                    KategorijaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_kategorije = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kategorija", x => x.KategorijaID);
                });

            migrationBuilder.CreateTable(
                name: "Proizvodjac",
                columns: table => new
                {
                    ProizvodjacID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_proizvodjaca = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_proizvodjac", x => x.ProizvodjacID);
                });

            migrationBuilder.CreateTable(
                name: "Uloge",
                columns: table => new
                {
                    UlogaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_uloge = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_uloga", x => x.UlogaID);
                });

            migrationBuilder.CreateTable(
                name: "Usluge",
                columns: table => new
                {
                    UslugeID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_usluge = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    opis = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    cijena = table.Column<decimal>(type: "decimal(8,2)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_usluge", x => x.UslugeID);
                });

            migrationBuilder.CreateTable(
                name: "Vozilos",
                columns: table => new
                {
                    VoziloId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MarkaVozila = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Vozilos", x => x.VoziloId);
                });

            migrationBuilder.CreateTable(
                name: "Grad",
                columns: table => new
                {
                    GradID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_grada = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    drzavaID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_grad", x => x.GradID);
                    table.ForeignKey(
                        name: "fk_d_g",
                        column: x => x.drzavaID,
                        principalTable: "Drzava",
                        principalColumn: "DrzavaID");
                });

            migrationBuilder.CreateTable(
                name: "Model",
                columns: table => new
                {
                    ModelId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NazivModela = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    VoziloId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Model", x => x.ModelId);
                    table.ForeignKey(
                        name: "FK_Model_Vozilos_VoziloId",
                        column: x => x.VoziloId,
                        principalTable: "Vozilos",
                        principalColumn: "VoziloId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Autoservis",
                columns: table => new
                {
                    AutoservisID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    adresa = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    gradID = table.Column<int>(type: "int", nullable: true),
                    telefon = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    email = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    password_ = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    jib = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    MBS = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    slika_Profila = table.Column<string>(type: "varchar(40)", unicode: false, maxLength: 40, nullable: true),
                    ulogaID = table.Column<int>(type: "int", nullable: true),
                    uslugeID = table.Column<int>(type: "int", nullable: true),
                    voziloID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_autoservis", x => x.AutoservisID);
                    table.ForeignKey(
                        name: "fk_autoservis_grad",
                        column: x => x.gradID,
                        principalTable: "Grad",
                        principalColumn: "GradID");
                    table.ForeignKey(
                        name: "fk_u_a",
                        column: x => x.uslugeID,
                        principalTable: "Usluge",
                        principalColumn: "UslugeID");
                    table.ForeignKey(
                        name: "fk_uloga_autoservis",
                        column: x => x.ulogaID,
                        principalTable: "Uloge",
                        principalColumn: "UlogaID");
                    table.ForeignKey(
                        name: "fk_v_a",
                        column: x => x.voziloID,
                        principalTable: "Vozilos",
                        principalColumn: "VoziloId");
                });

            migrationBuilder.CreateTable(
                name: "Firma_autodijelova",
                columns: table => new
                {
                    FirmaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv_firme = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    adresa = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    gradID = table.Column<int>(type: "int", nullable: true),
                    telefon = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    email = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    password_ = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    slika_Profila = table.Column<string>(type: "varchar(40)", unicode: false, maxLength: 40, nullable: true),
                    ulogaID = table.Column<int>(type: "int", nullable: true),
                    JIB = table.Column<int>(type: "int", nullable: true),
                    MBS = table.Column<int>(type: "int", nullable: true),
                    izvjestajID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_firma", x => x.FirmaID);
                    table.ForeignKey(
                        name: "fk_autoservis_grads",
                        column: x => x.gradID,
                        principalTable: "Grad",
                        principalColumn: "GradID");
                    table.ForeignKey(
                        name: "fk_i_fad",
                        column: x => x.izvjestajID,
                        principalTable: "Izvjestaj",
                        principalColumn: "IzvjestajID");
                    table.ForeignKey(
                        name: "fk_uloga_firmaautodijelova",
                        column: x => x.ulogaID,
                        principalTable: "Uloge",
                        principalColumn: "UlogaID");
                });

            migrationBuilder.CreateTable(
                name: "Klijent",
                columns: table => new
                {
                    KlijentID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ime = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    prezime = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    username = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    email = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    password_ = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    spol = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: true),
                    broj_telefona = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    gradID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_klijent", x => x.KlijentID);
                    table.ForeignKey(
                        name: "fk_klijent_grad",
                        column: x => x.gradID,
                        principalTable: "Grad",
                        principalColumn: "GradID");
                });

            migrationBuilder.CreateTable(
                name: "Godiste",
                columns: table => new
                {
                    GodisteId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Godiste_ = table.Column<int>(type: "int", nullable: true),
                    ModelId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Godiste", x => x.GodisteId);
                    table.ForeignKey(
                        name: "FK_Godiste_Model_ModelId",
                        column: x => x.ModelId,
                        principalTable: "Model",
                        principalColumn: "ModelId");
                });

            migrationBuilder.CreateTable(
                name: "placanje_autoservis_dijelovi",
                columns: table => new
                {
                    PlacanjeID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    datum = table.Column<DateTime>(type: "datetime", nullable: true),
                    iznos = table.Column<double>(type: "float", nullable: true),
                    AutoservisId = table.Column<int>(type: "int", nullable: true),
                    FirmaAutodijelovaID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_pl", x => x.PlacanjeID);
                    table.ForeignKey(
                        name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                        column: x => x.AutoservisId,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "FK_placanje_autoservis_dijelovi_Firma_autodijelova_FirmaAutodijelovaID",
                        column: x => x.FirmaAutodijelovaID,
                        principalTable: "Firma_autodijelova",
                        principalColumn: "FirmaID");
                });

            migrationBuilder.CreateTable(
                name: "Popust",
                columns: table => new
                {
                    PopustID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    autoservis_id = table.Column<int>(type: "int", nullable: true),
                    firma_autodijelovaID = table.Column<int>(type: "int", nullable: true),
                    vrijednost_popusta = table.Column<double>(type: "float", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_popust", x => x.PopustID);
                    table.ForeignKey(
                        name: "fk_autoservis_popust",
                        column: x => x.autoservis_id,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "fk_firma_Popust",
                        column: x => x.firma_autodijelovaID,
                        principalTable: "Firma_autodijelova",
                        principalColumn: "FirmaID");
                });

            migrationBuilder.CreateTable(
                name: "Proizvod",
                columns: table => new
                {
                    ProizvodID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    naziv = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    cijena = table.Column<decimal>(type: "money", nullable: true),
                    CijenaSaPopustom = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    Popust = table.Column<int>(type: "int", nullable: true),
                    sifra = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    originalni_broj = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    model = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    opis = table.Column<string>(type: "text", nullable: true),
                    kategorijaID = table.Column<int>(type: "int", nullable: true),
                    VoziloId = table.Column<int>(type: "int", nullable: true),
                    proizvodjacID = table.Column<int>(type: "int", nullable: true),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    SlikaThumb = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    StateMachine = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    FirmaAutodijelovaID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_proizvod", x => x.ProizvodID);
                    table.ForeignKey(
                        name: "FK_Proizvod_Vozilos_VoziloId",
                        column: x => x.VoziloId,
                        principalTable: "Vozilos",
                        principalColumn: "VoziloId");
                    table.ForeignKey(
                        name: "FK__Proizvod__FirmaAutodijelova",
                        column: x => x.FirmaAutodijelovaID,
                        principalTable: "Firma_autodijelova",
                        principalColumn: "FirmaID");
                    table.ForeignKey(
                        name: "fk_kategorija_proizvod",
                        column: x => x.kategorijaID,
                        principalTable: "Kategorija",
                        principalColumn: "KategorijaID");
                    table.ForeignKey(
                        name: "fk_proizvodjac_proizvod",
                        column: x => x.proizvodjacID,
                        principalTable: "Proizvodjac",
                        principalColumn: "ProizvodjacID");
                });

            migrationBuilder.CreateTable(
                name: "Zaposlenik",
                columns: table => new
                {
                    ZaposlenikID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ime = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    prezime = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    datum_rodjenja = table.Column<DateTime>(type: "date", nullable: true),
                    email = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    username = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    password_ = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    LozinkaSalt = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LozinkaHash = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    autoservisID = table.Column<int>(type: "int", nullable: true),
                    firma_autodijelovaID = table.Column<int>(type: "int", nullable: true),
                    UlogaId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_zaposlenik", x => x.ZaposlenikID);
                    table.ForeignKey(
                        name: "FK_Zaposlenik_Uloge_UlogaId",
                        column: x => x.UlogaId,
                        principalTable: "Uloge",
                        principalColumn: "UlogaID");
                    table.ForeignKey(
                        name: "fk_firma_zaposlenik",
                        column: x => x.firma_autodijelovaID,
                        principalTable: "Firma_autodijelova",
                        principalColumn: "FirmaID");
                    table.ForeignKey(
                        name: "fk_zaposlenik_autoservis",
                        column: x => x.autoservisID,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                });

            migrationBuilder.CreateTable(
                name: "Chat_klijent_servis",
                columns: table => new
                {
                    ChatKlijentServisID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    datum = table.Column<DateTime>(type: "datetime", nullable: true),
                    sadrzaj = table.Column<string>(type: "text", nullable: true),
                    autoservis_id = table.Column<int>(type: "int", nullable: true),
                    klijent_id = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_chat", x => x.ChatKlijentServisID);
                    table.ForeignKey(
                        name: "fk_autoservis_chat",
                        column: x => x.autoservis_id,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "fk_klijent_chat",
                        column: x => x.klijent_id,
                        principalTable: "Klijent",
                        principalColumn: "KlijentID");
                });

            migrationBuilder.CreateTable(
                name: "Narudzba_Stavka",
                columns: table => new
                {
                    Narudzba_stavkaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    proizvodID = table.Column<int>(type: "int", nullable: true),
                    kolicina = table.Column<int>(type: "int", nullable: true),
                    cijena = table.Column<decimal>(type: "decimal(8,2)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_ns", x => x.Narudzba_stavkaID);
                    table.ForeignKey(
                        name: "fk_ns_p",
                        column: x => x.proizvodID,
                        principalTable: "Proizvod",
                        principalColumn: "ProizvodID");
                });

            migrationBuilder.CreateTable(
                name: "Chat_klijent_zaposlenik",
                columns: table => new
                {
                    ChatKlijentZaposlenikID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    datum = table.Column<DateTime>(type: "datetime", nullable: true),
                    sadrzaj = table.Column<string>(type: "text", nullable: true),
                    zaposlenik_id = table.Column<int>(type: "int", nullable: true),
                    klijent_id = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_chat2", x => x.ChatKlijentZaposlenikID);
                    table.ForeignKey(
                        name: "fk_klijent_chat2",
                        column: x => x.klijent_id,
                        principalTable: "Klijent",
                        principalColumn: "KlijentID");
                    table.ForeignKey(
                        name: "fk_zaposlenik_chat2",
                        column: x => x.zaposlenik_id,
                        principalTable: "Zaposlenik",
                        principalColumn: "ZaposlenikID");
                });

            migrationBuilder.CreateTable(
                name: "Zaposlenik_Proizvod",
                columns: table => new
                {
                    zaposlenikID = table.Column<int>(type: "int", nullable: false),
                    proizvodID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Zaposlen__50FD668EDF7047CD", x => new { x.zaposlenikID, x.proizvodID });
                    table.ForeignKey(
                        name: "FK__Zaposleni__proiz__7C4F7684",
                        column: x => x.proizvodID,
                        principalTable: "Proizvod",
                        principalColumn: "ProizvodID");
                    table.ForeignKey(
                        name: "FK__Zaposleni__zapos__7B5B524B",
                        column: x => x.zaposlenikID,
                        principalTable: "Zaposlenik",
                        principalColumn: "ZaposlenikID");
                });

            migrationBuilder.CreateTable(
                name: "Narudzba",
                columns: table => new
                {
                    NarudzbaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    narudzbaStavkeID = table.Column<int>(type: "int", nullable: true),
                    datum_narudzbe = table.Column<DateTime>(type: "date", nullable: true),
                    datum_isporuke = table.Column<DateTime>(type: "date", nullable: true),
                    zavrsena_narudzba = table.Column<bool>(type: "bit", nullable: true),
                    popustID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_n", x => x.NarudzbaID);
                    table.ForeignKey(
                        name: "fk_n_p",
                        column: x => x.popustID,
                        principalTable: "Popust",
                        principalColumn: "PopustID");
                    table.ForeignKey(
                        name: "fk_ns_n",
                        column: x => x.narudzbaStavkeID,
                        principalTable: "Narudzba_Stavka",
                        principalColumn: "Narudzba_stavkaID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Autoservis_gradID",
                table: "Autoservis",
                column: "gradID");

            migrationBuilder.CreateIndex(
                name: "IX_Autoservis_ulogaID",
                table: "Autoservis",
                column: "ulogaID");

            migrationBuilder.CreateIndex(
                name: "IX_Autoservis_uslugeID",
                table: "Autoservis",
                column: "uslugeID");

            migrationBuilder.CreateIndex(
                name: "IX_Autoservis_voziloID",
                table: "Autoservis",
                column: "voziloID");

            migrationBuilder.CreateIndex(
                name: "IX_Chat_klijent_servis_autoservis_id",
                table: "Chat_klijent_servis",
                column: "autoservis_id");

            migrationBuilder.CreateIndex(
                name: "IX_Chat_klijent_servis_klijent_id",
                table: "Chat_klijent_servis",
                column: "klijent_id");

            migrationBuilder.CreateIndex(
                name: "IX_Chat_klijent_zaposlenik_klijent_id",
                table: "Chat_klijent_zaposlenik",
                column: "klijent_id");

            migrationBuilder.CreateIndex(
                name: "IX_Chat_klijent_zaposlenik_zaposlenik_id",
                table: "Chat_klijent_zaposlenik",
                column: "zaposlenik_id");

            migrationBuilder.CreateIndex(
                name: "IX_Firma_autodijelova_gradID",
                table: "Firma_autodijelova",
                column: "gradID");

            migrationBuilder.CreateIndex(
                name: "IX_Firma_autodijelova_izvjestajID",
                table: "Firma_autodijelova",
                column: "izvjestajID");

            migrationBuilder.CreateIndex(
                name: "IX_Firma_autodijelova_ulogaID",
                table: "Firma_autodijelova",
                column: "ulogaID");

            migrationBuilder.CreateIndex(
                name: "IX_Godiste_ModelId",
                table: "Godiste",
                column: "ModelId");

            migrationBuilder.CreateIndex(
                name: "IX_Grad_drzavaID",
                table: "Grad",
                column: "drzavaID");

            migrationBuilder.CreateIndex(
                name: "IX_Klijent_gradID",
                table: "Klijent",
                column: "gradID");

            migrationBuilder.CreateIndex(
                name: "IX_Model_VoziloId",
                table: "Model",
                column: "VoziloId");

            migrationBuilder.CreateIndex(
                name: "IX_Narudzba_narudzbaStavkeID",
                table: "Narudzba",
                column: "narudzbaStavkeID");

            migrationBuilder.CreateIndex(
                name: "IX_Narudzba_popustID",
                table: "Narudzba",
                column: "popustID");

            migrationBuilder.CreateIndex(
                name: "IX_Narudzba_Stavka_proizvodID",
                table: "Narudzba_Stavka",
                column: "proizvodID");

            migrationBuilder.CreateIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_placanje_autoservis_dijelovi_FirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi",
                column: "FirmaAutodijelovaID");

            migrationBuilder.CreateIndex(
                name: "IX_Popust_autoservis_id",
                table: "Popust",
                column: "autoservis_id");

            migrationBuilder.CreateIndex(
                name: "IX_Popust_firma_autodijelovaID",
                table: "Popust",
                column: "firma_autodijelovaID");

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_FirmaAutodijelovaID",
                table: "Proizvod",
                column: "FirmaAutodijelovaID");

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_kategorijaID",
                table: "Proizvod",
                column: "kategorijaID");

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_proizvodjacID",
                table: "Proizvod",
                column: "proizvodjacID");

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_VoziloId",
                table: "Proizvod",
                column: "VoziloId");

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_autoservisID",
                table: "Zaposlenik",
                column: "autoservisID");

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_firma_autodijelovaID",
                table: "Zaposlenik",
                column: "firma_autodijelovaID");

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_UlogaId",
                table: "Zaposlenik",
                column: "UlogaId");

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_Proizvod_proizvodID",
                table: "Zaposlenik_Proizvod",
                column: "proizvodID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Chat_klijent_servis");

            migrationBuilder.DropTable(
                name: "Chat_klijent_zaposlenik");

            migrationBuilder.DropTable(
                name: "Godiste");

            migrationBuilder.DropTable(
                name: "Narudzba");

            migrationBuilder.DropTable(
                name: "placanje_autoservis_dijelovi");

            migrationBuilder.DropTable(
                name: "Zaposlenik_Proizvod");

            migrationBuilder.DropTable(
                name: "Klijent");

            migrationBuilder.DropTable(
                name: "Model");

            migrationBuilder.DropTable(
                name: "Popust");

            migrationBuilder.DropTable(
                name: "Narudzba_Stavka");

            migrationBuilder.DropTable(
                name: "Zaposlenik");

            migrationBuilder.DropTable(
                name: "Proizvod");

            migrationBuilder.DropTable(
                name: "Autoservis");

            migrationBuilder.DropTable(
                name: "Firma_autodijelova");

            migrationBuilder.DropTable(
                name: "Kategorija");

            migrationBuilder.DropTable(
                name: "Proizvodjac");

            migrationBuilder.DropTable(
                name: "Usluge");

            migrationBuilder.DropTable(
                name: "Vozilos");

            migrationBuilder.DropTable(
                name: "Grad");

            migrationBuilder.DropTable(
                name: "Izvjestaj");

            migrationBuilder.DropTable(
                name: "Uloge");

            migrationBuilder.DropTable(
                name: "Drzava");
        }
    }
}
