using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Narudzba
{
    public int NarudzbaId { get; set; }

    public int? NarudzbaStavkeId { get; set; }

    public DateTime? DatumNarudzbe { get; set; }

    public DateTime? DatumIsporuke { get; set; }

    public bool? ZavrsenaNarudzba { get; set; }

    public int? PopustId { get; set; }

    public virtual NarudzbaStavka? NarudzbaStavke { get; set; }

    public virtual Popust? Popust { get; set; }
}
