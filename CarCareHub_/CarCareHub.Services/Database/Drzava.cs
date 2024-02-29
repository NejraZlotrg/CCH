using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Drzava
{
    public int DrzavaId { get; set; }

    public string? NazivDrzave { get; set; }

    public virtual ICollection<Grad> Grads { get; set; } = new List<Grad>();
}
