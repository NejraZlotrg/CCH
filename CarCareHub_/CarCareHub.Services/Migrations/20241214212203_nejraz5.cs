using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class nejraz5 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AutoservisId",
                table: "Korpas",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "KlijentId",
                table: "Korpas",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ZaposlenikId",
                table: "Korpas",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Korpas_AutoservisId",
                table: "Korpas",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_Korpas_KlijentId",
                table: "Korpas",
                column: "KlijentId");

            migrationBuilder.CreateIndex(
                name: "IX_Korpas_ZaposlenikId",
                table: "Korpas",
                column: "ZaposlenikId");

            migrationBuilder.AddForeignKey(
                name: "FK_Korpas_Autoservis_AutoservisId",
                table: "Korpas",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_Korpas_Klijent_KlijentId",
                table: "Korpas",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "FK_Korpas_Zaposlenik_ZaposlenikId",
                table: "Korpas",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Korpas_Autoservis_AutoservisId",
                table: "Korpas");

            migrationBuilder.DropForeignKey(
                name: "FK_Korpas_Klijent_KlijentId",
                table: "Korpas");

            migrationBuilder.DropForeignKey(
                name: "FK_Korpas_Zaposlenik_ZaposlenikId",
                table: "Korpas");

            migrationBuilder.DropIndex(
                name: "IX_Korpas_AutoservisId",
                table: "Korpas");

            migrationBuilder.DropIndex(
                name: "IX_Korpas_KlijentId",
                table: "Korpas");

            migrationBuilder.DropIndex(
                name: "IX_Korpas_ZaposlenikId",
                table: "Korpas");

            migrationBuilder.DropColumn(
                name: "AutoservisId",
                table: "Korpas");

            migrationBuilder.DropColumn(
                name: "KlijentId",
                table: "Korpas");

            migrationBuilder.DropColumn(
                name: "ZaposlenikId",
                table: "Korpas");
        }
    }
}
