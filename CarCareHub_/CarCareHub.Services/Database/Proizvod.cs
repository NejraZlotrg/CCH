using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;
public partial class Proizvod
{
    public int ProizvodId { get; set; }
    public string? Naziv { get; set; }
    public decimal? Cijena { get; set; }
    public decimal? CijenaSaPopustom { get; set; }
    public int? Popust { get; set; }

    public string? Sifra { get; set; }
    public string? OriginalniBroj { get; set; }
    public string? Model { get; set; }
    public string? Opis { get; set; }
    public int? KategorijaId { get; set; }
    public virtual Kategorija? Kategorija { get; set; }
    public int? VoziloId { get; set; } // Foreign key

    public virtual Vozilo? Vozilo { get; set; }
    public int? ProizvodjacId { get; set; }
    public byte[]? Slika { get; set; }
    public byte[]? SlikaThumb { get; set; }
    public string? StateMachine { get; set; }
    public int? FirmaAutodijelovaID { get; set; }
    public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }

    // Navigation properties
    public virtual ICollection<NarudzbaStavka> NarudzbaStavkas { get; set; } = new List<NarudzbaStavka>();
    public virtual Proizvodjac? Proizvodjac { get; set; }
    public virtual ICollection<Zaposlenik> Zaposleniks { get; set; } = new List<Zaposlenik>();
}