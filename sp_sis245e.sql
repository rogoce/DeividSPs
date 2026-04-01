

DROP PROCEDURE sp_sis245e;
CREATE PROCEDURE "informix".sp_sis245e() 
returning
integer			as err,
			integer			as error_isam,
			varchar(100)	as descrip,
			varchar(100)	as descripcion,
			dec(16,2)       as prima_neta,
			dec(16,2)       as prima_resultado;
			
DEFINE _no_documento	CHAR(20);
DEFINE _no_poliza		CHAR(10);
DEFINE _no_unidad		CHAR(5);
DEFINE _desc_error		varCHAR(50);
DEFINE _error_desc		varCHAR(50);
DEFINE _mensaje			varCHAR(50);
DEFINE _valor			varCHAR(50);
DEFINE _error			smallint;
DEFINE _return			smallint;
DEFINE _vigencia_inic	DATE;
DEFINE _fecha_hoy 		DATE;
DEFINE _ld_prima_neta_t DEC(16,2);
DEFINE _prima_neta, _prima_neta_sin, _suma_asegurada, _prima_resultado, v_prima_neta  DEC(16,2);
DEFINE _calculo         DEC(5,2);
DEFINE _cod_producto    CHAR(5);


--set debug file to "sp_sis245e.trc";
--trace on;


SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;

FOREACH
    select a.no_documento, 
	       a.no_unidad,
		   b.no_poliza_r
	  into _no_documento,
           _no_unidad,
           _no_poliza		   
      from deivid_tmp:renov_recar a, deivid_tmp:renov_recar b
     where a.procesado = 0
       and a.no_documento = b.no_documento
       and a.no_unidad = b.no_unidad
       and b.procesado = 3
    --   and b.no_poliza_r in ('2587726','2587728')

	update emipomae 
	   set actualizado = 0
	 where no_poliza = _no_poliza;
	 
	update endedmae 
	   set actualizado = 0
	 where no_poliza = _no_poliza
	   and no_endoso = '00000';
	   
	delete from emiunide
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_descuen = '001';
	     
--	 where no_poliza = _no_poliza;
	   
	   
--    insert into emiunide
--	values (_no_poliza,
--	       _no_unidad,
--		   '001',
--		   -6.30,
--		   1);

	

--	update emiunide
--	   set porc_descuento = 9
--	 where no_poliza = _no_poliza;
	 

	call sp_pro323(_no_poliza,_no_unidad,0,'001') returning _valor;
	if _valor <> 0 then
		return _valor,_mensaje,'','',0,0;
	end if	   
	
	
	call sp_proe01bk(_no_poliza, _no_unidad, '001') returning _valor;
	
	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	   
	let _ld_prima_neta_t = 0;   
	
	select sum(e.prima_neta)
	  into _ld_prima_neta_t
	  from emipocob e, prdcobpd c
	 where e.no_poliza = _no_poliza
	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and c.cod_producto = _cod_producto
	   and c.acepta_desc = 1;
	   
	if _ld_prima_neta_t is null then
		let _ld_prima_neta_t = 0;
    end if	

	let _prima_neta_sin = 0;   

	select sum(e.prima_neta)
	  into _prima_neta_sin
	  from emipocob e, prdcobpd c
	 where e.no_poliza = _no_poliza
	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and c.cod_producto = _cod_producto
	   and c.acepta_desc = 0;
	   
	if _prima_neta_sin is null then
		let _prima_neta_sin = 0;
    end if	
	   
	select prima_neta
      into _prima_neta
      from deivid_tmp:renov_recar
     where no_documento = _no_documento
       and no_unidad = _no_unidad
	   and procesado = 0;	

    let v_prima_neta = _prima_neta;	   
	   
	if _ld_prima_neta_t = 0 and _prima_neta_sin <> 0 then
		let _ld_prima_neta_t = _prima_neta_sin;
	    let _prima_neta_sin = 0;
	end if	
	   
	LET _prima_neta = _prima_neta - _prima_neta_sin;   
	
    LET _calculo = ((_prima_neta - _ld_prima_neta_t) / _ld_prima_neta_t ) * 100;
	
    insert into emiunide
	values (_no_poliza,
	       _no_unidad,
		   '001',
		   _calculo * (-1),
		   1);

	call sp_proe01bk(_no_poliza, _no_unidad, '001') returning _valor;	

	select suma_asegurada
	  into _suma_asegurada
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	
	call sp_proe04apm(_no_poliza, _no_unidad, _suma_asegurada, '001') returning _valor;
	
--	call sp_pro323(_no_poliza,_no_unidad, _suma_asegurada,'001') returning _valor;
--	if _valor <> 0 then
--		return _valor,_mensaje,'','';
--	end if	   
	

	call sp_proe02(_no_poliza,_no_unidad,'001') returning _valor;
	
	call sp_proe03(_no_poliza,'001') returning _valor;
	
	select prima_neta
	  into _prima_resultado
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;	
	
	
    call sp_borra_endoso(_no_poliza, '00001') returning _valor, _desc_error;	   
	
	if _valor = 0 then
		call sp_sis17(_no_poliza) returning _return;

		if _return <> 0 Then
			if _return = 2 then
			   return 1,1,'Información', 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...',0,0;
			elif _return = 3 then
				let _desc_error = 'Esta Póliza DEBE llevar Impuesto, Por Favor Verifique ...';
				return 1,1,'Información', _desc_error,0,0;
			elif _return = 4 then
				let _desc_error = 'La Sumatoria de porcentajes de Prima/Suma diferente de 100%, por favor verifique ...';
			elif _return = 5 then
				let _desc_error = 'El Numero de Recibo de Pago es Obligatorio, por favor verifique ...';
			elif _return = 7 then
				let _desc_error = 'El porcentaje de participacion de los agentes debe sumar 100.00';
			elif _return = 9 then
				let _desc_error = 'La Póliza no se puede emitir porque el Vehículo esta Bloqueado';
			elif _return = 10 then
				let _desc_error = 'El sistema ha detectado una restricción con este cliente. Por favor verique...';
			else		
				select descripcion
				  into _desc_error
				  from inserror
				 where tipo_error = 2
				   and code_error = _return;	   
			end if
			
			return 1,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza),_desc_error,0,0 with resume;
			continue foreach;
		end if

	    update deivid_tmp:renov_recar
		   set actualizado = 1,
			   prima_resultado = _prima_resultado,
			   no_poliza_r = _no_poliza,
			   procesado = 1
		 where no_documento = _no_documento
		   and no_unidad = _no_unidad
		   and procesado = 0;
		
		return 0,0,_no_poliza,_no_poliza, v_prima_neta, _prima_resultado with resume;
	else
		return _valor,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza),_error_desc,0,0 with resume;
	end if
	
	
--	return 0,0,_no_documento,_no_poliza, v_prima_neta, _prima_resultado with resume;
END FOREACH

END PROCEDURE;