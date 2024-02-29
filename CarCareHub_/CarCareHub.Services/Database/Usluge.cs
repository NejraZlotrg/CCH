using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Usluge
{
    public int UslugeId { get; set; }

    public string? NazivUsluge { get; set; }

    public string? Opis { get; set; }

    public decimal? Cijena { get; set; }

    public virtual ICollection<Autoservi> Autoservis { get; set; } = new List<Autoservi>();
}
