using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class asadsxaxas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ChatAUtoservisKlijents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KlijentId = table.Column<int>(type: "int", nullable: false),
                    AutoservisId = table.Column<int>(type: "int", nullable: false),
                    Poruka = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PoslanoOdKlijenta = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeSlanja = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatAUtoservisKlijents", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatAUtoservisKlijents_Autoservis_AutoservisId",
                        column: x => x.AutoservisId,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ChatAUtoservisKlijents_Klijent_KlijentId",
                        column: x => x.KlijentId,
                        principalTable: "Klijent",
                        principalColumn: "KlijentID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChatAUtoservisKlijents_AutoservisId",
                table: "ChatAUtoservisKlijents",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatAUtoservisKlijents_KlijentId",
                table: "ChatAUtoservisKlijents",
                column: "KlijentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChatAUtoservisKlijents");
        }
    }
}
