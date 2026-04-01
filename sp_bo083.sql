drop procedure sp_bo083;

create procedure "informix".sp_bo083(_per_fin_aa char(7))
returning char(20),
          char(10),
		  char(7),
		  char(7),
		  char(7),
		  dec(16,2);

define _no_documento	char(20);
define _no_factura		char(10);
define _periodo			char(7);

define _ano_evaluar		smallint;
define _mes_pnd			smallint;
define _mes_evaluar		smallint;

define _periodo_pnd1	char(7);
define _periodo_pnd2	char(7);
define _pri_dev_aa		dec(16,2);

set debug file to "sp_bo083.trc";
trace on;

let _ano_evaluar = _per_fin_aa[1,4];
let _mes_evaluar = _per_fin_aa[6,7];

for _mes_pnd = _mes_evaluar to 1 step -1

	if _mes_pnd = 12 then

		let _periodo_pnd1 = _ano_evaluar || "-01";

	else
		
		if _mes_pnd < 10 then
			let _periodo_pnd1 = _ano_evaluar - 1 || "-0" || _mes_pnd + 1;
		else
			let _periodo_pnd1 = _ano_evaluar - 1 || "-" || _mes_pnd + 1;
		end if

	end if

	if _mes_pnd < 10 then
		let _periodo_pnd2 = _ano_evaluar || "-0" || _mes_pnd;
	else
		let _periodo_pnd2 = _ano_evaluar || "-" || _mes_pnd;
	end if

	return "",
	       "",
		   "",
		   _periodo_pnd1, 
		   _periodo_pnd2,
		   0
		   with resume;

	{
	foreach
	 select no_documento,
			no_factura,
			periodo,
	        prima_suscrita
	   into _no_documento,
			_no_factura,
			_periodo,
	        _pri_dev_aa
	   from endedmae
	  where periodo     >= _periodo_pnd1
	    and periodo     <= _periodo_pnd2
		and actualizado  = 1
		and no_documento = "0210-00132-06" 
	  order by 1, 2, 3

		let _pri_dev_aa = _pri_dev_aa / 12;

		return _no_documento,
		       _no_factura,
			   _periodo,
			   _periodo_pnd1, 
			   _periodo_pnd2,
			   _pri_dev_aa
			   with resume;

	end foreach
	}

end for

end procedure