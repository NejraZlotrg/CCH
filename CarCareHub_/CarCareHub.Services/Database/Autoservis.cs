using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Autoservis
{
    public int AutoservisId { get; set; }

    public string? Naziv { get; set; }

    public string? Adresa { get; set; }

    public int? GradId { get; set; }

    public string? Telefon { get; set; }

    public string? Email { get; set; }

    public string? Password { get; set; }

    public string? Jib { get; set; }

    public string? Mbs { get; set; }

    public string? SlikaProfila { get; set; }

    public int? UlogaId { get; set; }

    public int? UslugeId { get; set; }

    public int? VoziloId { get; set; }

    public virtual ICollection<ChatKlijentServis> ChatKlijentServiss { get; set; } = new List<ChatKlijentServis>();

    public virtual Grad? Grad { get; set; }

    public virtual ICollection<PlacanjeAutoservisDijelovi> PlacanjeAutoservisDijelovis { get; set; } = new List<PlacanjeAutoservisDijelovi>();


    public virtual Uloge? Uloga { get; set; }

    public virtual Usluge? Usluge { get; set; }

    public virtual Vozilo? Vozilo { get; set; }

    public virtual ICollection<Zaposlenik> Zaposleniks { get; set; } = new List<Zaposlenik>();
}
