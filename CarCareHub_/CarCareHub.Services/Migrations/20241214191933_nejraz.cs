using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class nejraz : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Korpa_Proizvod_ProizvodId",
                table: "Korpa");

            migrationBuilder.DropForeignKey(
                name: "FK_NarudzbaStavkas_Korpa_KorpaId",
                table: "NarudzbaStavkas");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Korpa",
                table: "Korpa");

            migrationBuilder.RenameTable(
                name: "Korpa",
                newName: "Korpas");

            migrationBuilder.RenameIndex(
                name: "IX_Korpa_ProizvodId",
                table: "Korpas",
                newName: "IX_Korpas_ProizvodId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Korpas",
                table: "Korpas",
                column: "KorpaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Korpas_Proizvod_ProizvodId",
                table: "Korpas",
                column: "ProizvodId",
                principalTable: "Proizvod",
                principalColumn: "ProizvodID");

            migrationBuilder.AddForeignKey(
                name: "FK_NarudzbaStavkas_Korpas_KorpaId",
                table: "NarudzbaStavkas",
                column: "KorpaId",
                principalTable: "Korpas",
                principalColumn: "KorpaId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Korpas_Proizvod_ProizvodId",
                table: "Korpas");

            migrationBuilder.DropForeignKey(
                name: "FK_NarudzbaStavkas_Korpas_KorpaId",
                table: "NarudzbaStavkas");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Korpas",
                table: "Korpas");

            migrationBuilder.RenameTable(
                name: "Korpas",
                newName: "Korpa");

            migrationBuilder.RenameIndex(
                name: "IX_Korpas_ProizvodId",
                table: "Korpa",
                newName: "IX_Korpa_ProizvodId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Korpa",
                table: "Korpa",
                column: "KorpaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Korpa_Proizvod_ProizvodId",
                table: "Korpa",
                column: "ProizvodId",
                principalTable: "Proizvod",
                principalColumn: "ProizvodID");

            migrationBuilder.AddForeignKey(
                name: "FK_NarudzbaStavkas_Korpa_KorpaId",
                table: "NarudzbaStavkas",
                column: "KorpaId",
                principalTable: "Korpa",
                principalColumn: "KorpaId");
        }
    }
}
