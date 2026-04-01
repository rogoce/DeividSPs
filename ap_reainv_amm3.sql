-- Procedimiento para barrer camrea2 e insertar nuevos registros en emifacon/cobreaco/rectrrea/recreaco producto de traspaso de cartera
-- correo enviado por Cesia 21/11/2022
-- Creado:     22/11/2022 - Autor Armando Moreno M.

drop procedure ap_reainv_amm3;
create procedure ap_reainv_amm3()
returning	integer;

define _error_desc			char(100);
define _error		        integer;
define _error_isam	        integer;
define _no_poliza_c,_no_endoso,_no_reclamo        char(10); 
define _max_no_cambio		smallint;
define _cod_contrato,_no_unidad  char(5);
define _cantidad,_flag,_renglon,_tipo_contrato            smallint;
define _no_documento char(20);
define _porc_partic_suma    dec(5,2);

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

-- buscar tipo de ramo, periodo de pago y tipo de produccion

--SERIE	TIPO	  ACTUAL	CAMBIO
--2018	CUOTA	  00689		00734
--2018	EXCEDENTE 00688		00733
--2019	CUOTA	  00695		00736
--2019	EXCEDENTE 00696		00735
--2020	CUOTA	  00704		00737
--2020	EXCEDENTE 00705		00738
--2021	CUOTA	  00714		00739
--2021	EXCEDENTE 00713		00740

--ESTE FUE EL SEGUNDO CAMBIO HECHO EN JULIO 2023
--Serie	Tipo	    Nuevo	Anterior
{2018	Cuota Parte	00750	00734
2018	Excedente	00755	00733
2019	Cuota Parte	00751	00735
2019	Excedente	00756	00736
2020	Cuota Parte	00752	00738
2020	Excedente	00757	00737
2021	Cuota Parte	00753	00739
2021	Excedente	00758	00740
2022	Cuota Parte	00754	00726
2022	Excedente	00759	00725
}

--TERCER CAMBIO ABRIL 2024
--CodContratoAnterior	NombreContratoAnterior	CodContratoNuevo	NombreContratoNuevo
--00760	RETENCION AUTO   2023	00766	RETENCION AUTO 2024    5.00 %
--00761	CUOTA PARTE AUTO 2023	00767	CUOTA PARTE AUTO 2024  95.00 %
--00762	FACULTATIVO AUTO 2024	00768	FACULTATIVO AUTO 2024

--PRODUCCION
foreach
	select no_poliza,
	       no_unidad,
		   no_endoso
	  into _no_poliza_c,
	       _no_unidad,
		   _no_endoso
	  from camrea2
	 where actualizado = 0
	   and tipo = 1
	 order by no_poliza,no_endoso,no_unidad

	foreach
		select cod_contrato
		  into _cod_contrato
		  from emifacon
		 where no_poliza = _no_poliza_c
	       and no_endoso = _no_endoso
	       and no_unidad = _no_unidad
		   
		select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = _cod_contrato; 		  		   
		  
		if _tipo_contrato = 1 then
			update emifacon
			   set cod_contrato = '00766',
			       porc_partic_suma = 5.00,
			       porc_partic_prima = 5.00
			 where cod_contrato = _cod_contrato
		       and no_poliza = _no_poliza_c
	           and no_endoso = _no_endoso
	           and no_unidad = _no_unidad;
		 
		end if
		
		if _tipo_contrato = 5 then
			update emifacon
			   set cod_contrato = '00767',
			       porc_partic_suma = 95.00,
			       porc_partic_prima = 95.00
			 where cod_contrato = _cod_contrato
		       and no_poliza = _no_poliza_c
	           and no_endoso = _no_endoso
	           and no_unidad = _no_unidad;
		end if
		if _tipo_contrato = 3 then
			update emifacon
			   set cod_contrato = '00768'
			 where cod_contrato = _cod_contrato
		       and no_poliza = _no_poliza_c
	           and no_endoso = _no_endoso
	           and no_unidad = _no_unidad;
	    end if
	end foreach

	update camrea2
	   set actualizado = 1
	 where tipo = 1
	   and no_poliza = _no_poliza_c
	   and no_endoso = _no_endoso
	   and no_unidad = _no_unidad;
	   
end foreach
--COBROS
foreach
	select no_endoso,
	       renglon
	  into _no_endoso,
		   _renglon
	  from camrea2
	 where actualizado = 0
	   and tipo = 2
	 order by no_endoso,renglon
	 
	foreach
		select cod_contrato
		  into _cod_contrato
		  from cobreaco
		 where no_remesa = _no_endoso
           and renglon   = _renglon		 
		  
		select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = _cod_contrato; 		  		   
		  
		if _tipo_contrato = 1 then
			update cobreaco
			   set cod_contrato = '00766',
			       porc_partic_suma = 5.00,
			       porc_partic_prima = 5.00
			 where cod_contrato = _cod_contrato
		       and no_remesa = _no_endoso
               and renglon   = _renglon;
		end if
		if _tipo_contrato = 5 then
			update cobreaco
			   set cod_contrato = '00767',
			       porc_partic_suma = 95.00,
			       porc_partic_prima = 95.00
			 where cod_contrato = _cod_contrato
		       and no_remesa = _no_endoso
               and renglon   = _renglon;
		end if
		if _tipo_contrato = 3 then
			update cobreaco
			   set cod_contrato = '00768'
			 where cod_contrato = _cod_contrato
		       and no_remesa = _no_endoso
               and renglon   = _renglon;
		end if
	end foreach

	update camrea2
	   set actualizado = 1
	 where tipo = 2
	   and no_endoso = _no_endoso
	   and renglon   = _renglon;
	   
end foreach
--RECLAMOS
foreach
	select no_endoso
	  into _no_endoso
	  from camrea2
	 where actualizado = 0
	   and tipo        = 3
	 order by no_endoso
	 
	select * from rectrrea
	 where no_tranrec = _no_endoso into temp prueba;
	   
	let _flag = 0;
	
	foreach
		select cod_contrato,
		       porc_partic_suma
		  into _cod_contrato,
		       _porc_partic_suma
		  from prueba
		  
		select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = _cod_contrato; 		  		   
		  
		if _tipo_contrato = 1 then
		    if _porc_partic_suma = 100 then
				update prueba
				   set cod_contrato = '00766'
				 where cod_contrato = _cod_contrato;
			else
				update prueba
				   set cod_contrato = '00766',
					   porc_partic_suma = 5.00,
					   porc_partic_prima = 5.00
				 where cod_contrato = _cod_contrato;
			end if
			let _flag = 1; 
		end if
		if _tipo_contrato = 5 then
			update prueba
			   set cod_contrato = '00767',
			       porc_partic_suma = 95.00,
			       porc_partic_prima = 95.00
			 where cod_contrato = _cod_contrato;
			let _flag = 1;
		end if
		if _tipo_contrato = 3 then
			update prueba
			   set cod_contrato = '00768'
			 where cod_contrato = _cod_contrato;
 			let _flag = 1; 
		end if
	end foreach

	if _flag = 1 then
		delete from rectrrea
		where no_tranrec = _no_endoso;

		insert into rectrrea
		select * from prueba;
		
		update camrea2
		   set actualizado = 1
		 where tipo = 3
		   and no_endoso = _no_endoso;
		   
		select no_reclamo
          into _no_reclamo
          from rectrmae
         where no_tranrec = _no_endoso;
		 
		select * from recreaco
		 where no_reclamo = _no_reclamo into temp prueba1;
		 
		let _flag = 0;
		
		foreach
			select cod_contrato,
			       porc_partic_suma
			  into _cod_contrato,
			       _porc_partic_suma			       
			  from prueba1
			  
			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato; 		  		   
			  
			if _tipo_contrato = 1 then
				if _porc_partic_suma = 100 then
					update prueba1
					   set cod_contrato = '00766'
					 where cod_contrato = _cod_contrato;
				else
					update prueba1
					   set cod_contrato = '00766',
						   porc_partic_suma = 5.00,
						   porc_partic_prima = 5.00
					 where cod_contrato = _cod_contrato;
				end if
				let _flag = 1; 
			end if
			if _tipo_contrato = 5 then
				update prueba1
				   set cod_contrato = '00767',
			           porc_partic_suma = 95.00,
			           porc_partic_prima = 95.00
				 where cod_contrato = _cod_contrato;
				let _flag = 1;
			end if
			if _tipo_contrato = 3 then
				update prueba1
				   set cod_contrato = '00768'
				 where cod_contrato = _cod_contrato;
				let _flag = 1; 
			end if
			  
		end foreach
        if _flag = 1 then
			delete from recreaco
			where no_reclamo = _no_reclamo;

			insert into recreaco
			select * from prueba1;
		end if
		
		drop table prueba1;	   
	end if
	drop table prueba;
end foreach

--CHEQUES
foreach
	select no_endoso
	  into _no_endoso
	  from camrea2
	 where actualizado = 0
	   and tipo = 4
	 order by no_endoso
	 
	foreach
		select cod_contrato
		  into _cod_contrato
		  from chqreaco
		 where no_requis = _no_endoso	 
		  
		select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = _cod_contrato; 		  		   
		  
		if _tipo_contrato = 1 then
			update chqreaco
			   set cod_contrato = '00766',
			       porc_partic_suma = 5.00,
			       porc_partic_prima = 5.00
			 where cod_contrato = _cod_contrato
		       and no_requis = _no_endoso;
		end if
		if _tipo_contrato = 5 then
			update chqreaco
			   set cod_contrato = '00767',
			       porc_partic_suma = 95.00,
			       porc_partic_prima = 95.00
			 where cod_contrato = _cod_contrato
		       and no_requis = _no_endoso;
		end if
		if _tipo_contrato = 3 then
			update chqreaco
			   set cod_contrato = '00768'
			 where cod_contrato = _cod_contrato
		       and no_requis = _no_endoso;
		end if
	end foreach

	update camrea2
	   set actualizado = 1
	 where tipo = 4
	   and no_endoso = _no_endoso;
	   
end foreach


--****RECLAMOS   HAY QUE ENTRAR A ESTE PROCEDIMIENTO Y PONER LOS CONTRATOS
--CALL ap_reainv_amm4() returning _no_documento,_no_poliza_c,_no_unidad,_cod_contrato;

return 0;
end
end procedure;