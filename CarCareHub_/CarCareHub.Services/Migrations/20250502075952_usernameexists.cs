using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class usernameexists : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_v_a",
                table: "Autoservis");

            migrationBuilder.RenameColumn(
                name: "voziloID",
                table: "Autoservis",
                newName: "VoziloId");

            migrationBuilder.RenameIndex(
                name: "IX_Autoservis_voziloID",
                table: "Autoservis",
                newName: "IX_Autoservis_VoziloId");

            migrationBuilder.AddForeignKey(
                name: "FK_Autoservis_Vozilos_VoziloId",
                table: "Autoservis",
                column: "VoziloId",
                principalTable: "Vozilos",
                principalColumn: "VoziloId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Autoservis_Vozilos_VoziloId",
                table: "Autoservis");

            migrationBuilder.RenameColumn(
                name: "VoziloId",
                table: "Autoservis",
                newName: "voziloID");

            migrationBuilder.RenameIndex(
                name: "IX_Autoservis_VoziloId",
                table: "Autoservis",
                newName: "IX_Autoservis_voziloID");

            migrationBuilder.AddForeignKey(
                name: "fk_v_a",
                table: "Autoservis",
                column: "voziloID",
                principalTable: "Vozilos",
                principalColumn: "VoziloId");
        }
    }
}
