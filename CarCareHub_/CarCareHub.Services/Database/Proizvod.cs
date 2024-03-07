using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Proizvod
{
    public int ProizvodId { get; set; }

    public string? Naziv { get; set; }

    public decimal? Cijena { get; set; }

    public string? Sifra { get; set; }

    public string? OriginalniBroj { get; set; }

    public string? Model { get; set; }

    public string? Opis { get; set; }

    public int? KategorijaId { get; set; }

    public int? ProizvodjacId { get; set; }

    public byte[]? Slika { get; set; }
    public byte[]? SlikaThumb { get; set; }


    public virtual Kategorija? Kategorija { get; set; }

    public virtual ICollection<NarudzbaStavka> NarudzbaStavkas { get; set; } = new List<NarudzbaStavka>();

    public virtual Proizvodjac? Proizvodjac { get; set; }

    public virtual ICollection<FirmaAutodijelova> Firmas { get; set; } = new List<FirmaAutodijelova>();

    public virtual ICollection<Zaposlenik> Zaposleniks { get; set; } = new List<Zaposlenik>();
}
