using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class treciMajaalaadaa : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "username",
                table: "Zaposlenik",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldUnicode: false,
                oldMaxLength: 20,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Zaposlenik",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldUnicode: false,
                oldMaxLength: 20,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "username",
                table: "Klijent",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Klijent",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldUnicode: false,
                oldMaxLength: 20,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Firma_autodijelova",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "email",
                table: "Firma_autodijelova",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Autoservis",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "email",
                table: "Autoservis",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                collation: "Latin1_General_CS_AS",
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "username",
                table: "Zaposlenik",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldUnicode: false,
                oldMaxLength: 20,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Zaposlenik",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldUnicode: false,
                oldMaxLength: 20,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "username",
                table: "Klijent",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Klijent",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldUnicode: false,
                oldMaxLength: 20,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Firma_autodijelova",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "email",
                table: "Firma_autodijelova",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "password_",
                table: "Autoservis",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");

            migrationBuilder.AlterColumn<string>(
                name: "email",
                table: "Autoservis",
                type: "varchar(30)",
                unicode: false,
                maxLength: 30,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(30)",
                oldUnicode: false,
                oldMaxLength: 30,
                oldNullable: true,
                oldCollation: "Latin1_General_CS_AS");
        }
    }
}
