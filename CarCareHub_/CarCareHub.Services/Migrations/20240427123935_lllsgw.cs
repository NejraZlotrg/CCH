using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class lllsgw : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChatKlijentZaposleniks_Autoservis_AutoservisId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatKlijentZaposleniks_Klijent_KlijentId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatKlijentZaposleniks_Zaposlenik_ZaposlenikId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_ChatKlijentZaposleniks_ChatKlijentZaposlenikId",
                table: "Poruka");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Drzavas",
                table: "Drzavas");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ChatKlijentZaposleniks",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.RenameTable(
                name: "Drzavas",
                newName: "Drzava");

            migrationBuilder.RenameTable(
                name: "ChatKlijentZaposleniks",
                newName: "Chat_klijent_zaposlenik");

            migrationBuilder.RenameColumn(
                name: "DrzavaId",
                table: "Drzava",
                newName: "DrzavaID");

            migrationBuilder.RenameColumn(
                name: "NazivDrzave",
                table: "Drzava",
                newName: "naziv_drzave");

            migrationBuilder.RenameIndex(
                name: "IX_ChatKlijentZaposleniks_ZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_ZaposlenikId");

            migrationBuilder.RenameIndex(
                name: "IX_ChatKlijentZaposleniks_KlijentId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_KlijentId");

            migrationBuilder.RenameIndex(
                name: "IX_ChatKlijentZaposleniks_AutoservisId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_AutoservisId");

            migrationBuilder.AlterColumn<string>(
                name: "naziv_drzave",
                table: "Drzava",
                type: "varchar(50)",
                unicode: false,
                maxLength: 50,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_drzava",
                table: "Drzava",
                column: "DrzavaID");

            migrationBuilder.AddPrimaryKey(
                name: "pk_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "ChatKlijentZaposlenikId");

            migrationBuilder.AddForeignKey(
                name: "FK_Chat_klijent_zaposlenik_Autoservis_AutoservisId",
                table: "Chat_klijent_zaposlenik",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

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
                name: "FK_Poruka_Chat_klijent_zaposlenik_ChatKlijentZaposlenikId",
                table: "Poruka",
                column: "ChatKlijentZaposlenikId",
                principalTable: "Chat_klijent_zaposlenik",
                principalColumn: "ChatKlijentZaposlenikId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Chat_klijent_zaposlenik_Autoservis_AutoservisId",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_Chat_klijent_zaposlenik_ChatKlijentZaposlenikId",
                table: "Poruka");

            migrationBuilder.DropPrimaryKey(
                name: "PK_drzava",
                table: "Drzava");

            migrationBuilder.DropPrimaryKey(
                name: "pk_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.RenameTable(
                name: "Drzava",
                newName: "Drzavas");

            migrationBuilder.RenameTable(
                name: "Chat_klijent_zaposlenik",
                newName: "ChatKlijentZaposleniks");

            migrationBuilder.RenameColumn(
                name: "DrzavaID",
                table: "Drzavas",
                newName: "DrzavaId");

            migrationBuilder.RenameColumn(
                name: "naziv_drzave",
                table: "Drzavas",
                newName: "NazivDrzave");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_ZaposlenikId",
                table: "ChatKlijentZaposleniks",
                newName: "IX_ChatKlijentZaposleniks_ZaposlenikId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_KlijentId",
                table: "ChatKlijentZaposleniks",
                newName: "IX_ChatKlijentZaposleniks_KlijentId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_AutoservisId",
                table: "ChatKlijentZaposleniks",
                newName: "IX_ChatKlijentZaposleniks_AutoservisId");

            migrationBuilder.AlterColumn<string>(
                name: "NazivDrzave",
                table: "Drzavas",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(50)",
                oldUnicode: false,
                oldMaxLength: 50,
                oldNullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Drzavas",
                table: "Drzavas",
                column: "DrzavaId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ChatKlijentZaposleniks",
                table: "ChatKlijentZaposleniks",
                column: "ChatKlijentZaposlenikId");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatKlijentZaposleniks_Autoservis_AutoservisId",
                table: "ChatKlijentZaposleniks",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatKlijentZaposleniks_Klijent_KlijentId",
                table: "ChatKlijentZaposleniks",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatKlijentZaposleniks_Zaposlenik_ZaposlenikId",
                table: "ChatKlijentZaposleniks",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID");

            migrationBuilder.AddForeignKey(
                name: "FK_Poruka_ChatKlijentZaposleniks_ChatKlijentZaposlenikId",
                table: "Poruka",
                column: "ChatKlijentZaposlenikId",
                principalTable: "ChatKlijentZaposleniks",
                principalColumn: "ChatKlijentZaposlenikId");
        }
    }
}
