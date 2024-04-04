using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Klijent
{
    public int KlijentId { get; set; }

    public string? Ime { get; set; }

    public string? Prezime { get; set; }

    public string? Username { get; set; }

    public string? Email { get; set; }

    public string? Password { get; set; }

    public string? Spol { get; set; }

    public string? BrojTelefona { get; set; }

    public int? GradId { get; set; }

    public virtual ICollection<ChatKlijentServis> ChatKlijentServis { get; set; } = new List<ChatKlijentServis>();

    public virtual ICollection<ChatKlijentZaposlenik> ChatKlijentZaposleniks { get; set; } = new List<ChatKlijentZaposlenik>();

    public virtual Grad? Grad { get; set; }
}
