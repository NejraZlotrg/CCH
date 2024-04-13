using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class FirmaAutodijelova
    {
        public int FirmaId { get; set; }

        public string? NazivFirme { get; set; }

        public string? Adresa { get; set; }

        public int? GradId { get; set; }

        public string? Telefon { get; set; }

        public string? Email { get; set; }

        public string? Password { get; set; }

        public string? SlikaProfila { get; set; }

        public int? UlogaId { get; set; }
        public virtual Grad? Grad { get; set; }
        public virtual Uloge? Uloga { get; set; }
        public int? JIB { get; set; }
        public int? MBS { get; set; }
        public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();

        //public virtual Drzava? Drzava { get; set; }


        // public int? IzvjestajId { get; set; }
    }
}
