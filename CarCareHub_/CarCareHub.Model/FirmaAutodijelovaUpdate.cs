using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class FirmaAutodijelovaUpdate
    {
        public string? NazivFirme { get; set; }

        public string? Username { get; set; }

        public string? Password { get; set; }

        public string? Adresa { get; set; }

        public string? Telefon { get; set; }

        public string? Email { get; set; }
        public int? GradId { get; set; }
        public int? JIB { get; set; }
        public int? MBS { get; set; }
        public byte[]? SlikaProfila { get; set; }

    }
}
