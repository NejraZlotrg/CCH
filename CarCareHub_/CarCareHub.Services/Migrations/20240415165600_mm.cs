using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mm : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "JIB",
                table: "Firma_autodijelova");

            migrationBuilder.DropColumn(
                name: "MBS",
                table: "Firma_autodijelova");
        }
    }
}
