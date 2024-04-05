using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mhk : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UlogeZaposlenik");

            migrationBuilder.AddColumn<int>(
                name: "UlogaId",
                table: "Zaposlenik",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Zaposlenik_UlogaId",
                table: "Zaposlenik",
                column: "UlogaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Zaposlenik_Uloge_UlogaId",
                table: "Zaposlenik",
                column: "UlogaId",
                principalTable: "Uloge",
                principalColumn: "UlogaID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Zaposlenik_Uloge_UlogaId",
                table: "Zaposlenik");

            migrationBuilder.DropIndex(
                name: "IX_Zaposlenik_UlogaId",
                table: "Zaposlenik");

            migrationBuilder.DropColumn(
                name: "UlogaId",
                table: "Zaposlenik");

            migrationBuilder.CreateTable(
                name: "UlogeZaposlenik",
                columns: table => new
                {
                    UlogesUlogaId = table.Column<int>(type: "int", nullable: false),
                    ZaposleniksZaposlenikId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UlogeZaposlenik", x => new { x.UlogesUlogaId, x.ZaposleniksZaposlenikId });
                    table.ForeignKey(
                        name: "FK_UlogeZaposlenik_Uloge_UlogesUlogaId",
                        column: x => x.UlogesUlogaId,
                        principalTable: "Uloge",
                        principalColumn: "UlogaID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UlogeZaposlenik_Zaposlenik_ZaposleniksZaposlenikId",
                        column: x => x.ZaposleniksZaposlenikId,
                        principalTable: "Zaposlenik",
                        principalColumn: "ZaposlenikID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UlogeZaposlenik_ZaposleniksZaposlenikId",
                table: "UlogeZaposlenik",
                column: "ZaposleniksZaposlenikId");
        }
    }
}
