using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class sjnidtzjhasas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "UlogaId",
                table: "Klijent",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Klijent_UlogaId",
                table: "Klijent",
                column: "UlogaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Klijent_Uloge_UlogaId",
                table: "Klijent",
                column: "UlogaId",
                principalTable: "Uloge",
                principalColumn: "UlogaID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Klijent_Uloge_UlogaId",
                table: "Klijent");

            migrationBuilder.DropIndex(
                name: "IX_Klijent_UlogaId",
                table: "Klijent");

            migrationBuilder.DropColumn(
                name: "UlogaId",
                table: "Klijent");
        }
    }
}
