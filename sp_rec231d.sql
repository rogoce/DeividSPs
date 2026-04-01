 													   
drop procedure sp_rec231d;

create procedure sp_rec231d(a_no_ajus_orden char(10), a_orden char(10), a_tipo_opc smallint)
returning integer,		  
          varchar(100);

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(10);
define _error           integer;
define _cod_proveedor   char(10);
define _cnt, _renglon   smallint;
define _renglon_str     varchar(5);
define _anular_nt       char(10);
define _no_tranrec      char(10);
define _transaccion     char(10);
define _pagado          smallint;
define _no_requis       char(10);
define _anulado			smallint; 

--SET DEBUG FILE TO "sp_rec231a.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin


let _mto_orden = 0.00;
let _error     = 0;
let _cnt       = 0;
let _anulado   = 0;

--if a_tipo_opc = 5 then
--	let a_tipo_opc = 0;
--end if

select count(*)
  into _cnt
  from recordad
 where no_ajus_orden = a_no_ajus_orden
   and no_orden = a_orden
   and tipo_opc = a_tipo_opc;

if _cnt > 0 then
	select renglon
	  into _renglon
	  from recordad
	 where no_ajus_orden = a_no_ajus_orden
	   and no_orden = a_orden
	   and renglon  is not null
	   and tipo_opc = a_tipo_opc;

 	let _renglon_str = _renglon;

	return -1, "Esta orden ya se ingreso en el renglon " || trim(_renglon_str);
end if


let _transaccion = null;

select trans_pend
  into _transaccion
  from recordma
 where no_orden = a_orden;

if _transaccion is null then
	select transaccion
	  into _transaccion
	  from recordma
	 where no_orden = a_orden;
end if

select count(*)
  into _cnt
  from recordad
 where no_ajus_orden = a_no_ajus_orden
   and transaccion_alq = _transaccion
   and tipo_opc = 6;

if _cnt > 0 then
	select renglon
	  into _renglon
	  from recordad
	 where no_ajus_orden = a_no_ajus_orden
	   and transaccion_alq = _transaccion
	   and renglon  is not null
	   and tipo_opc = 6;

 	let _renglon_str = _renglon;

	return -1, "Esta orden tiene una transaccion " || trim(_transaccion) || " que se ingreso en el renglon " || trim(_renglon_str);
end if

let _transaccion = null;

Select no_tranrec
  into _no_tranrec
  from recordma
 where no_orden = a_orden;

let _anular_nt = null;
 
Select transaccion,
       pagado,
       no_requis
  into _transaccion,
       _pagado,
       _no_requis
  from rectrmae
 where no_tranrec = _no_tranrec;
 
if _pagado = 0 then	
	select max(no_requis) 
	  into _no_requis 
	  from chqchrec 
	 where transaccion = _transaccion;
	 

	if _no_requis is not null and trim(_no_requis) <> "" then
		 select anulado
		   into _anulado
		   from chqchmae
		  where no_requis = _no_requis;
		  
	    if _anulado = 1 then
			return 0, "";
		end if
		return -1,  "La Transaccion " || _transaccion || " esta pendiente de pago en la requisicion " || _no_requis ;
	end if
else
	if _no_requis is not null and trim(_no_requis) <> "" then
		return -1,  "La Transaccion " || _transaccion || " fue pagada en la requisicion " || _no_requis ;
	else
		return -1,  "La Transaccion " || _transaccion || " fue anulada";
	end if
end if

return 0, "";

end

end procedure