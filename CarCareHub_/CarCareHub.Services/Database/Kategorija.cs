using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Kategorija
{
    public int KategorijaId { get; set; }

    public string? NazivKategorije { get; set; }

    public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
    public bool Vidljivo { get; set; }
}
