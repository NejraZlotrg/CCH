using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Proizvod
    {
        public int ProizvodId { get; set; }

        public string? Naziv { get; set; }

        public decimal? Cijena { get; set; }
        public decimal? CijenaSaPopustom { get; set; }
        public int? Popust { get; set; }

        public string? Sifra { get; set; }
        public bool Vidljivo { get; set; }
        public string? OriginalniBroj { get; set; }
        public decimal? CijenaSaPopustomZaAutoservis { get; set; }

        public string? ModelProizvoda { get; set; }

        public string? Opis { get; set; }

        public int? KategorijaId { get; set; }
        public virtual Kategorija Kategorija { get; set; }

        ///
        public int FirmaAutodijelovaID { get; set; }
        public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }


        public int? ModelId { get; set; } // Foreign key
        public virtual Model? Model { get; set; }

        public int? ProizvodjacId { get; set; }
        public virtual Proizvodjac Proizvodjac { get; set; }

        public byte[]? Slika { get; set; }
        public byte[]? SlikaThumb { get; set; }
        public string StateMachine { get; set; }

    }
}