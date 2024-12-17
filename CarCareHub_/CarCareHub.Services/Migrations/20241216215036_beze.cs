using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class beze : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ProizvodId",
                table: "NarudzbaStavkas",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_NarudzbaStavkas_ProizvodId",
                table: "NarudzbaStavkas",
                column: "ProizvodId");

            migrationBuilder.AddForeignKey(
                name: "FK_NarudzbaStavkas_Proizvod_ProizvodId",
                table: "NarudzbaStavkas",
                column: "ProizvodId",
                principalTable: "Proizvod",
                principalColumn: "ProizvodID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NarudzbaStavkas_Proizvod_ProizvodId",
                table: "NarudzbaStavkas");

            migrationBuilder.DropIndex(
                name: "IX_NarudzbaStavkas_ProizvodId",
                table: "NarudzbaStavkas");

            migrationBuilder.DropColumn(
                name: "ProizvodId",
                table: "NarudzbaStavkas");
        }
    }
}
