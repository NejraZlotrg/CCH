using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class firmaautodijelovastzjtrgz5bjhzu6jvh57b8nčuigč : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<byte[]>(
                name: "slika_Profila",
                table: "Firma_autodijelova",
                type: "VARBINARY(MAX)",
                unicode: false,
                maxLength: 40,
                nullable: true,
                oldClrType: typeof(byte[]),
                oldType: "varbinary(40)",
                oldUnicode: false,
                oldMaxLength: 40,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LozinkaHash",
                table: "Firma_autodijelova",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LozinkaSalt",
                table: "Firma_autodijelova",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LozinkaHash",
                table: "Firma_autodijelova");

            migrationBuilder.DropColumn(
                name: "LozinkaSalt",
                table: "Firma_autodijelova");

            migrationBuilder.AlterColumn<byte[]>(
                name: "slika_Profila",
                table: "Firma_autodijelova",
                type: "varbinary(40)",
                unicode: false,
                maxLength: 40,
                nullable: true,
                oldClrType: typeof(byte[]),
                oldType: "VARBINARY(MAX)",
                oldUnicode: false,
                oldMaxLength: 40,
                oldNullable: true);
        }
    }
}
