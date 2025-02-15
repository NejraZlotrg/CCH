using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class bazaza : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatAutoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatAutoservisKlijents_Klijent_KlijentId",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropForeignKey(
                name: "FK_Klijent_Uloge_UlogaId",
                table: "Klijent");

            migrationBuilder.DropForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model");

            migrationBuilder.DropForeignKey(
                name: "FK_Model_Vozilos_VoziloId",
                table: "Model");

            migrationBuilder.DropForeignKey(
                name: "FK_Zaposlenik_Uloge_UlogaId",
                table: "Zaposlenik");

            migrationBuilder.AddForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAutoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAutoservisKlijents",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAutoservisKlijents_Klijent_KlijentId",
                table: "ChatAutoservisKlijents",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Klijent_Uloge_UlogaId",
                table: "Klijent",
                column: "UlogaId",
                principalTable: "Uloge",
                principalColumn: "UlogaID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model",
                column: "GodisteId",
                principalTable: "Godiste",
                principalColumn: "GodisteId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Vozilos_VoziloId",
                table: "Model",
                column: "VoziloId",
                principalTable: "Vozilos",
                principalColumn: "VoziloId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Zaposlenik_Uloge_UlogaId",
                table: "Zaposlenik",
                column: "UlogaId",
                principalTable: "Uloge",
                principalColumn: "UlogaID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatAutoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatAutoservisKlijents_Klijent_KlijentId",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropForeignKey(
                name: "FK_Klijent_Uloge_UlogaId",
                table: "Klijent");

            migrationBuilder.DropForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model");

            migrationBuilder.DropForeignKey(
                name: "FK_Model_Vozilos_VoziloId",
                table: "Model");

            migrationBuilder.DropForeignKey(
                name: "FK_Zaposlenik_Uloge_UlogaId",
                table: "Zaposlenik");

            migrationBuilder.AddForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAutoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAutoservisKlijents",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAutoservisKlijents_Klijent_KlijentId",
                table: "ChatAutoservisKlijents",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "FK_Klijent_Uloge_UlogaId",
                table: "Klijent",
                column: "UlogaId",
                principalTable: "Uloge",
                principalColumn: "UlogaID");

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model",
                column: "GodisteId",
                principalTable: "Godiste",
                principalColumn: "GodisteId");

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Vozilos_VoziloId",
                table: "Model",
                column: "VoziloId",
                principalTable: "Vozilos",
                principalColumn: "VoziloId");

            migrationBuilder.AddForeignKey(
                name: "FK_Zaposlenik_Uloge_UlogaId",
                table: "Zaposlenik",
                column: "UlogaId",
                principalTable: "Uloge",
                principalColumn: "UlogaID");
        }
    }
}
