using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mhgzz7 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AutoservisId",
                table: "Narudzbas",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "KlijentId",
                table: "Narudzbas",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ZaposlenikId",
                table: "Narudzbas",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Narudzbas_AutoservisId",
                table: "Narudzbas",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_Narudzbas_KlijentId",
                table: "Narudzbas",
                column: "KlijentId");

            migrationBuilder.CreateIndex(
                name: "IX_Narudzbas_ZaposlenikId",
                table: "Narudzbas",
                column: "ZaposlenikId");

            migrationBuilder.AddForeignKey(
                name: "FK_Narudzbas_Autoservis_AutoservisId",
                table: "Narudzbas",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_Narudzbas_Klijent_KlijentId",
                table: "Narudzbas",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "FK_Narudzbas_Zaposlenik_ZaposlenikId",
                table: "Narudzbas",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Narudzbas_Autoservis_AutoservisId",
                table: "Narudzbas");

            migrationBuilder.DropForeignKey(
                name: "FK_Narudzbas_Klijent_KlijentId",
                table: "Narudzbas");

            migrationBuilder.DropForeignKey(
                name: "FK_Narudzbas_Zaposlenik_ZaposlenikId",
                table: "Narudzbas");

            migrationBuilder.DropIndex(
                name: "IX_Narudzbas_AutoservisId",
                table: "Narudzbas");

            migrationBuilder.DropIndex(
                name: "IX_Narudzbas_KlijentId",
                table: "Narudzbas");

            migrationBuilder.DropIndex(
                name: "IX_Narudzbas_ZaposlenikId",
                table: "Narudzbas");

            migrationBuilder.DropColumn(
                name: "AutoservisId",
                table: "Narudzbas");

            migrationBuilder.DropColumn(
                name: "KlijentId",
                table: "Narudzbas");

            migrationBuilder.DropColumn(
                name: "ZaposlenikId",
                table: "Narudzbas");
        }
    }
}
