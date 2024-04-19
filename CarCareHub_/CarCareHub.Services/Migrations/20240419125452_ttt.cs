using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class ttt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "BrojTelefona",
                table: "Zaposlenik",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "GradId",
                table: "Zaposlenik",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MaticniBroj",
                table: "Zaposlenik",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_GradId",
                table: "Zaposlenik",
                column: "GradId");

            migrationBuilder.AddForeignKey(
                name: "FK_Zaposlenik_Grad_GradId",
                table: "Zaposlenik",
                column: "GradId",
                principalTable: "Grad",
                principalColumn: "GradID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Zaposlenik_Grad_GradId",
                table: "Zaposlenik");

            migrationBuilder.DropIndex(
                name: "IX_Zaposlenik_GradId",
                table: "Zaposlenik");

            migrationBuilder.DropColumn(
                name: "BrojTelefona",
                table: "Zaposlenik");

            migrationBuilder.DropColumn(
                name: "GradId",
                table: "Zaposlenik");

            migrationBuilder.DropColumn(
                name: "MaticniBroj",
                table: "Zaposlenik");
        }
    }
}
