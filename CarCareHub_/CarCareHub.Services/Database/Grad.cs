using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Grad
{
    public int GradId { get; set; }

    public string? NazivGrada { get; set; }

    public int? DrzavaId { get; set; }

    public virtual ICollection<Autoservi> Autoservis { get; set; } = new List<Autoservi>();

    public virtual Drzava? Drzava { get; set; }

    public virtual ICollection<FirmaAutodijelova> FirmaAutodijelovas { get; set; } = new List<FirmaAutodijelova>();

    public virtual ICollection<Klijent> Klijents { get; set; } = new List<Klijent>();
}
