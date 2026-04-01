

DROP PROCEDURE sp_sis245c;
CREATE PROCEDURE "informix".sp_sis245c() 
returning
integer			as err,
			integer			as error_isam,
			varchar(100)	as descrip,
			varchar(100)	as descripcion;
			
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
DEFINE _prima_neta, _prima_neta_sin, _suma_asegurada, _prima_resultado  DEC(16,2);
DEFINE _calculo         DEC(5,2);
DEFINE _cod_producto    CHAR(5);


--set debug file to "sp_sis245c.trc";
--trace on;


SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;

FOREACH
	select emi.no_documento,
		   emi.no_poliza,
		   uni.no_unidad
	  into _no_documento,
		   _no_poliza,
		   _no_unidad
	  from emipomae emi
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza
	 where emi.no_poliza in ('2587180') --,'2585319','2585348'
	/* where emi.no_poliza in ('2540398','2540399','2540400','2540401','2540402','2540403','2540404','2540405','2540406','2540407','2540408','2540409','2540411','2540412','2540413','2540414','2540415','2540416','2540417','2540418','2540421',
	                         '2540422','2540423','2540425','2540426','2540427','2540428','2540429','2540430','2540431','2540432','2540434','2540435','2540436','2540437','2540438','2540439','2540440','2540442','2540443','2540444','2540445',
							 '2540446','2540447','2540448','2540449','2540450','2540451','2540452','2540453','2540454','2540455','2540456','2540457','2540458','2540459','2540460','2540461','2540462','2540463','2540465','2540466','2540467',
							 '2540468','2540469','2540470','2540471','2540472','2540473','2540481','2540482','2540483','2540484','2540485','2540486','2540487','2540488','2540489','2540490','2540491','2540492','2540493','2540495','2540497','2540499',
							 '2540501','2540502','2540503','2540504','2540505','2540506','2540507','2540508','2540511','2540512','2540513','2540514','2540515','2540518','2540520','2540522','2540524','2540527','2540528','2540531','2540533','2540534',
							 '2540537','2540539','2540541','2540542','2540545','2540547','2540549','2540550','2540553','2540554','2540556','2540558','2540560','2540562','2540564','2540566','2540568','2540570','2540572','2540573','2540574','2540575',
							 '2540576','2540577','2540578','2540580','2540585','2540582','2540586','2540587','2540588','2540589','2540603','2540605','2540606','2540607','2540608','2540609','2540610','2540612','2540620','2540621','2540622','2540623',
							 '2540624','2540625','2540626','2540627','2540628','2540629','2540630','2540633','2540632','2540634','2540636','2540637','2540642','2540645','2540646','2540648','2540649','2540650','2540651','2540652','2540653','2540654',
							 '2540655','2540656','2540657','2540658','2540659','2540660','2540661','2540662','2540663','2540664','2540666','2540667','2540668','2540669','2540670','2540671','2540672','2540673','2540674','2540675','2540676','2540677',
							 '2540678','2540679','2540680','2540681','2540682','2540683','2540684','2540685','2540686','2540687','2540688','2540689','2540690','2540691','2540692','2540693','2540694','2540695','2540696','2540697','2540698','2540699',
							 '2540700','2540701','2540702','2540703','2540704','2540705','2540706','2540707','2540708','2540709','2540710')
      and emi.no_factura = '03-211746'*/
	  
{	select emi.no_documento,
		   emi.no_poliza,
		   uni.no_unidad
	  into _no_documento,
		   _no_poliza,
		   _no_unidad
	  from emipomae emi
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza
	 inner join emiunide des on des.no_poliza = emi.no_poliza and uni.no_unidad = des.no_unidad
	 inner join prdprod prd on prd.cod_producto = uni.cod_producto
	 where emi.no_poliza in ('2585262','2585319','2585348')
	/* where emi.no_poliza in ('2540398','2540399','2540400','2540401','2540402','2540403','2540404','2540405','2540406','2540407','2540408','2540409','2540411','2540412','2540413','2540414','2540415','2540416','2540417','2540418','2540421',
	                         '2540422','2540423','2540425','2540426','2540427','2540428','2540429','2540430','2540431','2540432','2540434','2540435','2540436','2540437','2540438','2540439','2540440','2540442','2540443','2540444','2540445',
							 '2540446','2540447','2540448','2540449','2540450','2540451','2540452','2540453','2540454','2540455','2540456','2540457','2540458','2540459','2540460','2540461','2540462','2540463','2540465','2540466','2540467',
							 '2540468','2540469','2540470','2540471','2540472','2540473','2540481','2540482','2540483','2540484','2540485','2540486','2540487','2540488','2540489','2540490','2540491','2540492','2540493','2540495','2540497','2540499',
							 '2540501','2540502','2540503','2540504','2540505','2540506','2540507','2540508','2540511','2540512','2540513','2540514','2540515','2540518','2540520','2540522','2540524','2540527','2540528','2540531','2540533','2540534',
							 '2540537','2540539','2540541','2540542','2540545','2540547','2540549','2540550','2540553','2540554','2540556','2540558','2540560','2540562','2540564','2540566','2540568','2540570','2540572','2540573','2540574','2540575',
							 '2540576','2540577','2540578','2540580','2540585','2540582','2540586','2540587','2540588','2540589','2540603','2540605','2540606','2540607','2540608','2540609','2540610','2540612','2540620','2540621','2540622','2540623',
							 '2540624','2540625','2540626','2540627','2540628','2540629','2540630','2540633','2540632','2540634','2540636','2540637','2540642','2540645','2540646','2540648','2540649','2540650','2540651','2540652','2540653','2540654',
							 '2540655','2540656','2540657','2540658','2540659','2540660','2540661','2540662','2540663','2540664','2540666','2540667','2540668','2540669','2540670','2540671','2540672','2540673','2540674','2540675','2540676','2540677',
							 '2540678','2540679','2540680','2540681','2540682','2540683','2540684','2540685','2540686','2540687','2540688','2540689','2540690','2540691','2540692','2540693','2540694','2540695','2540696','2540697','2540698','2540699',
							 '2540700','2540701','2540702','2540703','2540704','2540705','2540706','2540707','2540708','2540709','2540710')
      and emi.no_factura = '03-211746'*/
}
	update emipomae 
	   set actualizado = 0
	 where no_poliza = _no_poliza;
	 
	update endedmae 
	   set actualizado = 0
	 where no_poliza = _no_poliza
	   and no_endoso = '00000';
	   
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
		return _valor,_mensaje,'','';
	end if	   
	
	
	call sp_proe01bk(_no_poliza, _no_unidad, '001') returning _valor;
	
	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	
	select sum(e.prima_neta)
	  into _ld_prima_neta_t
	  from emipocob e, prdcobpd c
	 where e.no_poliza = _no_poliza
	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and c.cod_producto = _cod_producto
	   and c.acepta_desc = 1;

	select sum(e.prima_neta)
	  into _prima_neta_sin
	  from emipocob e, prdcobpd c
	 where e.no_poliza = _no_poliza
	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and c.cod_producto = _cod_producto
	   and c.acepta_desc = 0;
	   
	select prima_neta
      into _prima_neta
      from deivid_tmp:renov_recar
     where no_documento = _no_documento
       and no_unidad = _no_unidad;	 
	   
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
	
	call sp_proe04(_no_poliza, _no_unidad, _suma_asegurada, '001') returning _valor;
	
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
	
	if _valor = 0 then
		call sp_sis17(_no_poliza) returning _return;

		if _return <> 0 Then
			if _return = 2 then
			   return 1,1,'Información', 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...';
			elif _return = 3 then
				let _desc_error = 'Esta Póliza DEBE llevar Impuesto, Por Favor Verifique ...';
				return 1,1,'Información', _desc_error;
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
			
			return 1,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza),_desc_error with resume;
			continue foreach;
		end if

	    update deivid_tmp:renov_recar
		   set actualizado = 1,
			   prima_resultado = _prima_resultado
		 where no_poliza_r = _no_poliza
		   and no_unidad = _no_unidad;
		
		return 0,0,_no_poliza,_no_poliza with resume;
	else
		return _valor,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza),_error_desc with resume;
	end if
	
	
	return 0,0,_no_poliza,_no_poliza with resume;
END FOREACH

END PROCEDURE;