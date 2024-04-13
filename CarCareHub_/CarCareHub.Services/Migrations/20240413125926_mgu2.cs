using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mgu2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Firma_autodijelova_FirmaAutodijelovaFirmaId",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropIndex(
                name: "IX_placanje_autoservis_dijelovi_FirmaAutodijelovaFirmaId",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropColumn(
                name: "FirmaAutodijelovaFirmaId",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropColumn(
                name: "PosiljaocAutoservisID",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.RenameColumn(
                name: "AutoservisId",
                table: "placanje_autoservis_dijelovi",
                newName: "AutoservisID");

            migrationBuilder.RenameColumn(
                name: "PrimalacFirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi",
                newName: "FirmaAutodijelovaID");

            migrationBuilder.RenameIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                newName: "IX_placanje_autoservis_dijelovi_AutoservisID");

            migrationBuilder.CreateIndex(
                name: "IX_placanje_autoservis_dijelovi_FirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi",
                column: "FirmaAutodijelovaID");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisID",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisID",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Firma_autodijelova_FirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi",
                column: "FirmaAutodijelovaID",
                principalTable: "Firma_autodijelova",
                principalColumn: "FirmaID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisID",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Firma_autodijelova_FirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropIndex(
                name: "IX_placanje_autoservis_dijelovi_FirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.RenameColumn(
                name: "AutoservisID",
                table: "placanje_autoservis_dijelovi",
                newName: "AutoservisId");

            migrationBuilder.RenameColumn(
                name: "FirmaAutodijelovaID",
                table: "placanje_autoservis_dijelovi",
                newName: "PrimalacFirmaAutodijelovaID");

            migrationBuilder.RenameIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisID",
                table: "placanje_autoservis_dijelovi",
                newName: "IX_placanje_autoservis_dijelovi_AutoservisId");

            migrationBuilder.AddColumn<int>(
                name: "FirmaAutodijelovaFirmaId",
                table: "placanje_autoservis_dijelovi",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PosiljaocAutoservisID",
                table: "placanje_autoservis_dijelovi",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_placanje_autoservis_dijelovi_FirmaAutodijelovaFirmaId",
                table: "placanje_autoservis_dijelovi",
                column: "FirmaAutodijelovaFirmaId");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Firma_autodijelova_FirmaAutodijelovaFirmaId",
                table: "placanje_autoservis_dijelovi",
                column: "FirmaAutodijelovaFirmaId",
                principalTable: "Firma_autodijelova",
                principalColumn: "FirmaID");
        }
    }
}
