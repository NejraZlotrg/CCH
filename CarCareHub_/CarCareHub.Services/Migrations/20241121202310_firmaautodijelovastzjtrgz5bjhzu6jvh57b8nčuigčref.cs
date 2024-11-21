using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class firmaautodijelovastzjtrgz5bjhzu6jvh57b8nčuigčref : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "LozinkaHash",
                table: "Autoservis",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LozinkaSalt",
                table: "Autoservis",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Username",
                table: "Autoservis",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LozinkaHash",
                table: "Autoservis");

            migrationBuilder.DropColumn(
                name: "LozinkaSalt",
                table: "Autoservis");

            migrationBuilder.DropColumn(
                name: "Username",
                table: "Autoservis");
        }
    }
}
