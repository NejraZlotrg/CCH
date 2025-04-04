using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Runtime.Intrinsics.X86;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Autoservis
    {
        public int AutoservisId { get; set; }

        public string? Naziv { get; set; }

        public string? Adresa { get; set; }

        public string? VlasnikFirme { get; set; }

        public bool Vidljivo { get; set; }
        public int? GradId { get; set; }

        public string? Telefon { get; set; }

        public string? Email { get; set; }

        public string? Username { get; set; }

        public string? Password { get; set; }

        public string? LozinkaSalt { get; set; }
        public string? LozinkaHash { get; set; }

        public string? Jib { get; set; }

        public string? Mbs { get; set; }
        [Column(TypeName = "VARBINARY(MAX)")]
        public byte[]? SlikaProfila { get; set; }


        public int? UlogaId { get; set; }


        public int? VoziloId { get; set; }

        public virtual Grad? Grad { get; set; }

        public virtual Uloge? Uloga { get; set; }


        public virtual Vozilo? Vozilo { get; set; }

        public int? UslugeId { get; set; }
        public Usluge? Usluge { get; set; }


        public int? ZaposlenikId { get; set; }
        public Zaposlenik? Zapolenik { get; set; }
        //public virtual Drzava? Drzava { get; set; }

    }
}
