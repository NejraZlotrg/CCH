using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class FirmaAutodijelova
{
    public int FirmaAutodijelovaID { get; set; }

    public string? NazivFirme { get; set; }

    public string? Adresa { get; set; }

    public int? GradId { get; set; }

    public string? Telefon { get; set; }

    public string? Email { get; set; }

    public string? Password { get; set; }

    public string? SlikaProfila { get; set; }

    public int? UlogaId { get; set; }
    public int? JIB { get; set; }
    public int? MBS { get; set; }

    public int? IzvjestajId { get; set; }

    public virtual Grad? Grad { get; set; }

    public virtual Izvjestaj? Izvjestaj { get; set; }

    public virtual ICollection<PlacanjeAutoservisDijelovi> PlacanjeAutoservisDijelovis { get; set; } = new List<PlacanjeAutoservisDijelovi>();

    public virtual ICollection<Popust> Popusts { get; set; } = new List<Popust>();

    public virtual Uloge? Uloga { get; set; }

    public virtual ICollection<Zaposlenik> Zaposleniks { get; set; } = new List<Zaposlenik>();

    public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
}
