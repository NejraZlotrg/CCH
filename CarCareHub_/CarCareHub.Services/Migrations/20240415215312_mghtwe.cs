using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mghtwe : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "CijenaSaPopustom",
                table: "Proizvod",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Popust",
                table: "Proizvod",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CijenaSaPopustom",
                table: "Proizvod");

            migrationBuilder.DropColumn(
                name: "Popust",
                table: "Proizvod");
        }
    }
}
