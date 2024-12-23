using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class zlotrg : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_ChatKlijentAutoserviss_ChatKlijentAutoservisId",
                table: "Poruka");

            migrationBuilder.DropTable(
                name: "ChatKlijentAutoserviss");

            migrationBuilder.DropIndex(
                name: "IX_Poruka_ChatKlijentAutoservisId",
                table: "Poruka");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ChatKlijentAutoserviss",
                columns: table => new
                {
                    ChatKlijentAutoservisId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AutoservisId = table.Column<int>(type: "int", nullable: true),
                    KlijentId = table.Column<int>(type: "int", nullable: true),
                    VrijemeZadnjePoruke = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatKlijentAutoserviss", x => x.ChatKlijentAutoservisId);
                    table.ForeignKey(
                        name: "FK_ChatKlijentAutoserviss_Autoservis_AutoservisId",
                        column: x => x.AutoservisId,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "FK_ChatKlijentAutoserviss_Klijent_KlijentId",
                        column: x => x.KlijentId,
                        principalTable: "Klijent",
                        principalColumn: "KlijentID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Poruka_ChatKlijentAutoservisId",
                table: "Poruka",
                column: "ChatKlijentAutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatKlijentAutoserviss_AutoservisId",
                table: "ChatKlijentAutoserviss",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatKlijentAutoserviss_KlijentId",
                table: "ChatKlijentAutoserviss",
                column: "KlijentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Poruka_ChatKlijentAutoserviss_ChatKlijentAutoservisId",
                table: "Poruka",
                column: "ChatKlijentAutoservisId",
                principalTable: "ChatKlijentAutoserviss",
                principalColumn: "ChatKlijentAutoservisId");
        }
    }
}
