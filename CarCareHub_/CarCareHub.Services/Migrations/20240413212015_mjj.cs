using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mjj : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisID",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropTable(
                name: "Zaposlenik_Proizvod");

            migrationBuilder.RenameColumn(
                name: "AutoservisID",
                table: "placanje_autoservis_dijelovi",
                newName: "AutoservisId");

            migrationBuilder.RenameIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisID",
                table: "placanje_autoservis_dijelovi",
                newName: "IX_placanje_autoservis_dijelovi_AutoservisId");

            migrationBuilder.AddColumn<int>(
                name: "ProizvodId",
                table: "Zaposlenik",
                type: "int",
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "godiste_vozila",
                table: "Vozilo",
                type: "int",
                unicode: false,
                maxLength: 4,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(4)",
                oldUnicode: false,
                oldMaxLength: 4,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ModelVozila",
                table: "Vozilo",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "VoziloId",
                table: "Proizvod",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "JIB",
                table: "Firma_autodijelova",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MBS",
                table: "Firma_autodijelova",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FirmaAutodijelovaID",
                table: "Autoservis",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_ProizvodId",
                table: "Zaposlenik",
                column: "ProizvodId");

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_VoziloId",
                table: "Proizvod",
                column: "VoziloId");

            migrationBuilder.CreateIndex(
                name: "IX_Autoservis_FirmaAutodijelovaID",
                table: "Autoservis",
                column: "FirmaAutodijelovaID");

            migrationBuilder.AddForeignKey(
                name: "FK_Autoservis_Firma_autodijelova_FirmaAutodijelovaID",
                table: "Autoservis",
                column: "FirmaAutodijelovaID",
                principalTable: "Firma_autodijelova",
                principalColumn: "FirmaID");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_Proizvod_Vozilo_VoziloId",
                table: "Proizvod",
                column: "VoziloId",
                principalTable: "Vozilo",
                principalColumn: "VoziloID");

            migrationBuilder.AddForeignKey(
                name: "FK_Zaposlenik_Proizvod_ProizvodId",
                table: "Zaposlenik",
                column: "ProizvodId",
                principalTable: "Proizvod",
                principalColumn: "ProizvodID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Autoservis_Firma_autodijelova_FirmaAutodijelovaID",
                table: "Autoservis");

            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropForeignKey(
                name: "FK_Proizvod_Vozilo_VoziloId",
                table: "Proizvod");

            migrationBuilder.DropForeignKey(
                name: "FK_Zaposlenik_Proizvod_ProizvodId",
                table: "Zaposlenik");

            migrationBuilder.DropIndex(
                name: "IX_Zaposlenik_ProizvodId",
                table: "Zaposlenik");

            migrationBuilder.DropIndex(
                name: "IX_Proizvod_VoziloId",
                table: "Proizvod");

            migrationBuilder.DropIndex(
                name: "IX_Autoservis_FirmaAutodijelovaID",
                table: "Autoservis");

            migrationBuilder.DropColumn(
                name: "ProizvodId",
                table: "Zaposlenik");

            migrationBuilder.DropColumn(
                name: "ModelVozila",
                table: "Vozilo");

            migrationBuilder.DropColumn(
                name: "VoziloId",
                table: "Proizvod");

            migrationBuilder.DropColumn(
                name: "JIB",
                table: "Firma_autodijelova");

            migrationBuilder.DropColumn(
                name: "MBS",
                table: "Firma_autodijelova");

            migrationBuilder.DropColumn(
                name: "FirmaAutodijelovaID",
                table: "Autoservis");

            migrationBuilder.RenameColumn(
                name: "AutoservisId",
                table: "placanje_autoservis_dijelovi",
                newName: "AutoservisID");

            migrationBuilder.RenameIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                newName: "IX_placanje_autoservis_dijelovi_AutoservisID");

            migrationBuilder.AlterColumn<string>(
                name: "godiste_vozila",
                table: "Vozilo",
                type: "varchar(4)",
                unicode: false,
                maxLength: 4,
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int",
                oldUnicode: false,
                oldMaxLength: 4,
                oldNullable: true);

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

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_Proizvod_proizvodID",
                table: "Zaposlenik_Proizvod",
                column: "proizvodID");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisID",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisID",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");
        }
    }
}
