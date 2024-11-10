using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class AutoservisInsert
    {
        public string? Naziv { get; set; }

        public string? Adresa { get; set; }

        public int? GradId { get; set; }
        public string? VlasnikFirme { get; set; }
        public string? KorisnickoIme { get; set; }

        public string? Telefon { get; set; }

        public string? Email { get; set; }

        public string? Password { get; set; }

        public string? Jib { get; set; }

        public string? Mbs { get; set; }

        public byte[]? SlikaProfila { get; set; }

        public int? UlogaId { get; set; }
     



        public int? VoziloId { get; set; }

    }
}
