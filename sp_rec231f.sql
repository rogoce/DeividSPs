 													   
drop procedure sp_rec231f;

create procedure sp_rec231f(a_no_ajus_orden char(10), a_transaccion char(10))
returning integer,		  
          varchar(150);

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(10);
define _error           integer;
define _cod_proveedor   char(10);
define _cnt, _renglon   smallint;
define _renglon_str     varchar(5);
define _pagado          smallint;
define _no_requis       char(10);
define _anulado         smallint;
define _trans_pend      char(10);
define _cod_tipotran    char(3);

--SET DEBUG FILE TO "sp_rec231a.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin


let _mto_orden = 0.00;
let _error     = 0;
let _cnt       = 0;


select count(*)
  into _cnt
  from recordad
 where no_ajus_orden = a_no_ajus_orden
   and transaccion_alq = a_transaccion;

if _cnt > 0 then
	select renglon
	  into _renglon
	  from recordad
	 where no_ajus_orden = a_no_ajus_orden
	   and transaccion_alq = a_transaccion
	   and renglon  is not null;

 	let _renglon_str = _renglon;

	return -1, "Esta transaccion ya se ingreso en el renglon " || trim(_renglon_str);
end if

let _trans_pend = null;

foreach
	select renglon,
	       no_orden
	  into _renglon,
	       _no_orden
	  from recordad
	 where no_ajus_orden = a_no_ajus_orden
	   and renglon  is not null
	   and no_orden is not null
	   and trim(no_orden) <> ""
	   
	select trans_pend
	  into _trans_pend
	  from recordma
	 where no_orden = _no_orden;
	 
	if a_transaccion = _trans_pend then
		let _cnt = 1;
		exit foreach;
	end if
end foreach

if _cnt > 0 then
 	let _renglon_str = _renglon;
	return -1, "Esta transaccion ya se ingreso en la orden del renglon " || trim(_renglon_str);
end if

select pagado, no_requis, cod_tipotran
  into _pagado, _no_requis, _cod_tipotran
  from rectrmae
 where transaccion = a_transaccion;
 
if _cod_tipotran <> '004' then
		return -1,  "La Transaccion " || a_transaccion || " no es de pago";
end if 
 
if _pagado = 0 then	
	select max(no_requis) 
	  into _no_requis 
	  from chqchrec 
	 where transaccion = a_transaccion;
	 
	select anulado
	  into _anulado
	  from chqchmae
	 where no_requis = _no_requis;
	
	if _no_requis is not null and trim(_no_requis) <> "" and _anulado = 0 then
		return -1,  "La Transaccion " || a_transaccion || " esta pendiente de pago en la requisicion " || _no_requis ;
	end if
else
	if _no_requis is not null and trim(_no_requis) <> "" then
		return -1,  "La Transaccion " || a_transaccion || " fue pagada en la requisicion " || _no_requis ;
	else
		return -1,  "La Transaccion " || a_transaccion || " fue anulada";
	end if
end if

return 0, "";

end

end procedure