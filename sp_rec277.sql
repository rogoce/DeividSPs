-- Unificación de Requisiciones Pendientes de Pagar para los Reclamos de Salud y Accidentes
-- Para poder agregar mas transacciones de reclamos a una misma 
-- requisicion solo proveedores y hasta un limite
-- Se agrega el tipo de pago que está en la asignación para unificarlos los que son de un grupo determinado

-- Copia     : 01/03/2018 Del procedure sp_rec76

-- SIS v.2.0 - d_recl_tra_ayuda_requis2 - DEIVID, S.A.

drop procedure sp_rec277;

create procedure sp_rec277(a_cod_cliente char(10), a_no_tranrec char(10)
) returning date,
			char(10),
			char(100),
			dec(16,2);

define _no_requis		char(10);
define _fecha_captura	date;
define _nombre			char(100);
define _monto			dec(16,2);
define _numrecla        char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _ramo_sis        smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _descripcion		char(100);
define _cod_banco_r     char(3);
define _cod_chequera_r  char(3);
define _transaccion     char(10);
define _no_tranrec      char(10);
define _cant            smallint;
define _en_firma     	smallint;
define _tipo_requis     char(1);
define _ramo            char(2);
define _monto_tot       dec(16,2);
define _monto_tr        dec(16,2);
define _chq_limite_prov dec(16,2);
define _cod_asignacion  char(10);
define _cod_tipo        char(3);
define _cant_tipo       smallint;
define _cant_tipo_dif   smallint;

SET ISOLATION TO DIRTY READ;

---set debug file to "sp_rec277.trc";
--trace on;

let _monto_tot = 0.00;
let _monto_tr = 0.00;
let _chq_limite_prov = 0.00;
let _monto = 0.00;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_cliente;
 
select monto
  into _monto_tr
  from rectrmae
 where no_tranrec = a_no_tranrec;
 
select chq_limite_prov
  into _chq_limite_prov
  from parparam;
  
select cod_asignacion
  into _cod_asignacion
  from rectrmae
 where no_tranrec = a_no_tranrec;		   
  
select cod_tipo
  into _cod_tipo
  from atcdocde
 where cod_asignacion = _cod_asignacion;

--02-HONORARIOS MEDICOS                                	
--09-ACCIDENTE PERSONAL                                	
--23-GASTOS FUNERARIOS                                 	
--25-ASISTENCIA EN VIAJE                               	
--27-ATENCION MEDICA DOMICILIARIA                      	
--28-AMBULATORIA**	
 
if _cod_tipo in ('29','09','23','25','27','28') then 
	foreach
	 select	no_requis,
			fecha_captura,
			monto,
			cod_banco,
			cod_chequera,
			en_firma,
			tipo_requis
	   into	_no_requis,
			_fecha_captura,
			_monto,
			_cod_banco_r,
			_cod_chequera_r,
			_en_firma,
			_tipo_requis
	   from	chqchmae
	  where cod_cliente   = a_cod_cliente
		and pagado        = 0
		and anulado       = 0
		and origen_cheque in ("3","M")
		and en_firma	  in (0, 4, 5)
	 order by 1
	 
	 let _monto_tot = _monto + _monto_tr;
	 
	 if _monto_tot > _chq_limite_prov then
		continue foreach;
	 end if

	 let _cant = 0;

	 select count(*)	  
	   into _cant
	   from chqchrec
	  where no_requis = _no_requis;

	 if _cant = 0 then
		continue foreach;
	 end if
	 
	let _cant_tipo_dif = 0; 
	
	 select count(*)	  
	   into _cant_tipo_dif
	   from chqchrec a, rectrmae b, atcdocde c
	  where a.transaccion = b.transaccion
	    and b.cod_asignacion = c.cod_asignacion
	    and a.no_requis = _no_requis
		and c.cod_tipo not in ('29','09','23','25','27','28');
		
	if _cant_tipo_dif is null then
		let _cant_tipo_dif = 0;
	end if
	
	if _cant_tipo_dif > 0 then
		continue foreach;
	end if

	 foreach
		select numrecla,
			   transaccion
		  into _numrecla,
			   _transaccion
		  from chqchrec
		 where no_requis = _no_requis

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where numrecla = _numrecla
		   and actualizado = 1;

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _ramo_sis not in(5,9) then
		--	 return null,
		--			null,
		--			null,
		--			null;
			exit foreach;
			
		end if

	  end foreach

	 if _ramo_sis not in(5,9) then
		continue foreach;
	 end if

	 select cod_banco,
			cod_chequera
	   into _cod_banco,
			_cod_chequera
	   from chqbanch
	  where cod_ramo = _cod_ramo
		and cod_banco = '001';


	 if _cod_banco <> _cod_banco_r or _cod_chequera <> _cod_chequera_r then
			 return null,
					null,
					null,
					null;

		exit foreach;
	 end if

	 return _fecha_captura,
			_no_requis,
			_nombre,
			_monto;

	 exit foreach;
	end foreach
else
	foreach
	 select	no_requis,
			fecha_captura,
			monto,
			cod_banco,
			cod_chequera,
			en_firma,
			tipo_requis
	   into	_no_requis,
			_fecha_captura,
			_monto,
			_cod_banco_r,
			_cod_chequera_r,
			_en_firma,
			_tipo_requis
	   from	chqchmae
	  where cod_cliente   = a_cod_cliente
		and pagado        = 0
		and anulado       = 0
		and origen_cheque in ("3","M")
		and en_firma	  in (0, 4, 5)
	 order by 1

	 let _monto_tot = _monto + _monto_tr;
	 
	 if _monto_tot > _chq_limite_prov then
		continue foreach;
	 end if

	 let _cant = 0;

	 select count(*)	  
	   into _cant
	   from chqchrec
	  where no_requis = _no_requis;

	 if _cant = 0 then
		continue foreach;
	 end if
	 
	let _cant_tipo = 0; 
	let _cant_tipo_dif = 0; 
	
	 select count(*)	  
	   into _cant_tipo
	   from chqchrec a, rectrmae b, atcdocde c
	  where a.transaccion = b.transaccion
	    and b.cod_asignacion = c.cod_asignacion
	    and a.no_requis = _no_requis
		and c.cod_tipo in ('29','09','23','25','27','28');
		
	if _cant_tipo is null then
		let _cant_tipo = 0;
	end if
	
	if _cant_tipo > 0 then
		 select count(*)	  
		   into _cant_tipo_dif
		   from chqchrec a, rectrmae b, atcdocde c
		  where a.transaccion = b.transaccion
			and b.cod_asignacion = c.cod_asignacion
			and a.no_requis = _no_requis
			and c.cod_tipo not in ('29','09','23','25','27','28');
			
		if _cant_tipo_dif is null then
			let _cant_tipo_dif = 0;
		end if

		if _cant_tipo_dif = 0 then
			continue foreach;
		end if
	end if	 

	 foreach
		select numrecla,
			   transaccion
		  into _numrecla,
			   _transaccion
		  from chqchrec
		 where no_requis = _no_requis

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where numrecla = _numrecla
		   and actualizado = 1;

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _ramo_sis not in(5,9) then
		--	 return null,
		--			null,
		--			null,
		--			null;
			exit foreach;
			
		end if

	  end foreach

	 if _ramo_sis not in(5,9) then
		continue foreach;
	 end if

	 select cod_banco,
			cod_chequera
	   into _cod_banco,
			_cod_chequera
	   from chqbanch
	  where cod_ramo = _cod_ramo
		and cod_banco = '001';

	 if _cod_banco <> _cod_banco_r or _cod_chequera <> _cod_chequera_r then
			 return null,
					null,
					null,
					null;

		exit foreach;
	 end if
	 
	 return _fecha_captura,
			_no_requis,
			_nombre,
			_monto;

	 exit foreach;
	end foreach
end if
end procedure