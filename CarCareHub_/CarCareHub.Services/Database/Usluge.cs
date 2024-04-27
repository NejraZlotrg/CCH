using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Usluge
{
    public int UslugeId { get; set; }

    public string? NazivUsluge { get; set; }

    public string? Opis { get; set; }

    public decimal? Cijena { get; set; }
    public virtual ICollection<AutoservisUsluge> AutoservisUsluges { get; set; } = new List<AutoservisUsluge>();


}
