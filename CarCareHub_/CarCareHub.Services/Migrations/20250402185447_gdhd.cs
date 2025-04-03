using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class gdhd : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MaticniBroj",
                table: "Zaposlenik");

            migrationBuilder.AddColumn<int>(
                name: "mb",
                table: "Zaposlenik",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "mb",
                table: "Zaposlenik");

            migrationBuilder.AddColumn<int>(
                name: "MaticniBroj",
                table: "Zaposlenik",
                type: "int",
                nullable: true);
        }
    }
}
