-- Procedure que verifica los montos del detalle vs maestro ajuste de ordenes 													   
-- Creado por: Amado Perez 08/10/2014

drop procedure sp_rec233;

create procedure sp_rec233(a_ajus_orden char(10))
returning integer, varchar(150);

define _renglon         	smallint;
define _renglon_str     	varchar(5);
define _no_orden        	char(10);
define _error           	integer;
define _descripcion			varchar(150);
define _monto, _valor_ajust dec(16,2);
define _retorno         	integer;
define _sin_itbm        	dec(16,2);
define _monto_cal      	    dec(16,2);
define _transaccion         char(10);
define _no_requis           char(10);
define _pagado,_anulado     smallint;


--SET DEBUG FILE TO "sp_rec233.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 	RETURN _error, "Error en la verificacion de montos";         
END EXCEPTION

let _error   = 0;
let _retorno = 0;
let _anulado = 0;

let _descripcion = "Verificacion exitosa";

--delete from recordadd where no_ajus_orden =	a_ajus_orden and despachado = 0;

foreach	with hold
	select renglon, monto, no_orden
	  into _renglon, _monto, _no_orden
	  from recordad
	 where no_ajus_orden = a_ajus_orden
	   and tipo_opc = 0 
  order	by 1
  
  	let _renglon_str = _renglon;
  
    -- Aqui poner la validacion si ya se pago la transacción 	
	select transaccion
	  into _transaccion
	  from recordma
	 where no_orden = _no_orden;
	 
	select pagado, no_requis
	  into _pagado, _no_requis
	  from rectrmae
	 where transaccion = _transaccion;
	 
	if _pagado = 0  or _no_requis is null or trim(_no_requis) = "" then	
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
			else
				let _error = 1;
				let _descripcion = "La Transaccion " || _transaccion || " esta pendiente de pago en la requisicion " || _no_requis || " en el renglon " || _renglon_str;
				exit foreach;
			end if	
		end if
	else
		if _no_requis is not null and trim(_no_requis) <> "" then
			let _error = 1;
			let _descripcion = "La Transaccion " || _transaccion || " fue pagada en la requisicion " || _no_requis || " en el renglon " || _renglon_str;
			exit foreach;
		end if
	end if
	 
    let _retorno = sp_rec232(a_ajus_orden, _renglon, _no_orden); --> Si no hay registros en recordadd los inserta

	--Buscando sin impuesto

    let _sin_itbm = 0.00; 

    select sum(valor_ajust)
	  into _sin_itbm
	  from recordadd a, recparte b
	 where a.no_parte = b.no_parte
	   and no_ajus_orden = a_ajus_orden
	   and renglon = _renglon
	   and b.tiene_impuesto = 0;

    if _sin_itbm is null then
		let _sin_itbm = 0.00;
	end if

	let _valor_ajust = 0.00;

	select sum(valor_ajust)
	  into _valor_ajust
	  from recordadd
	 where no_ajus_orden = a_ajus_orden
	   and renglon       = _renglon;

    if _valor_ajust is null then
		let _valor_ajust = 0.00;
	end if

    --if _monto <= (ROUND((_valor_ajust +_valor_ajust * 0.07),2) + 0.02) or
    --   _monto >= (ROUND((_valor_ajust +_valor_ajust * 0.07),2) - 0.02) then
	let _monto_cal = _valor_ajust + ROUND(_valor_ajust * 0.07,2) - ROUND(_sin_itbm * 0.07,2);

    if _monto = _valor_ajust + ROUND(_valor_ajust * 0.07,2) - ROUND(_sin_itbm * 0.07,2) then
	else
		let _error = 1;
		let _descripcion = "Los montos no coinciden en el renglon " || _renglon_str;
	  	exit foreach;
    end if

end foreach

end
return _error, _descripcion;
end procedure