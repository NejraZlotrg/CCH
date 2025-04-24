using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class FirmaAutodijelovaUpdate
    {
        public string? NazivFirme { get; set; }
        public string? Username { get; set; }
        [Compare("PasswordAgain", ErrorMessage = "Pass don't match")]
        public string? Password { get; set; }
        [Compare("Password", ErrorMessage = "Pass don't match")]
        public string? PasswordAgain { get; set; }
        public string? Adresa { get; set; }
        public string? Telefon { get; set; }
        public string? Email { get; set; }
        public int? GradId { get; set; }
        public string? JIB { get; set; }
        public string? MBS { get; set; }
        public byte[]? SlikaProfila { get; set; }
    }
}
