using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mghtw : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "VoziloId",
                table: "Proizvod",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_VoziloId",
                table: "Proizvod",
                column: "VoziloId");

            migrationBuilder.AddForeignKey(
                name: "FK_Proizvod_Vozilo_VoziloId",
                table: "Proizvod",
                column: "VoziloId",
                principalTable: "Vozilo",
                principalColumn: "VoziloID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Proizvod_Vozilo_VoziloId",
                table: "Proizvod");

            migrationBuilder.DropIndex(
                name: "IX_Proizvod_VoziloId",
                table: "Proizvod");

            migrationBuilder.DropColumn(
                name: "VoziloId",
                table: "Proizvod");
        }
    }
}
