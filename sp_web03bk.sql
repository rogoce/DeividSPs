-- Procedure que carga los asegurados para la campana cinta rosada/celeste en la WEB

-- Creado: 15/07/2009 - Autor: Itzis Nunez Brown
-- Modificado: 12/08/2014 - Jaime Chevalier
-- Modificado: 22/08/2016 - Federico Coronado

drop procedure sp_web03bk;

create procedure "informix".sp_web03bk()
returning integer,
          char(100);

define _compania			char(3);
define _sucursal			char(3);
define _fecha_moros			date;
define _periodo_moros		char(7);

define _no_documento		char(20);
define _no_poliza			char(10);
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_subramo			char(3);
define _subramo_desc		char(20);
define _suma_asegurada		dec(16,2);
define _cod_contrat			char(10);
define _cod_sucursal		char(3);

define _procedimiento		char(40);
define _no_unidad			char(5);
define _fecha_siniestro		date;
define _cont_cpt			integer;
define _contador			integer;
define _dias				integer;
define _no_reclamo			char(10);


define _cod_contratante		char(10);
define _cod_cliente			char(10);
define _nom_contratante		char(100);
define _edad				integer;
define _fecha_aniversario	date;
define _sexo				char(1);
define _cod_asegurado		char(10);
define _telefono1			char(10);
define _telefono2			char(10);
define _email				char(50);



define _estatus_poliza		smallint;

define _moro_saldo			dec(16,2);
define _moro_por_vencer		dec(16,2);
define _moro_exigible		dec(16,2);
define _moro_corriente		dec(16,2);
define _moro_30				dec(16,2);
define _moro_60				dec(16,2);
define _moro_90				dec(16,2);


define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _cantidad			integer;
define _ano_fec_sini        integer;
define _fecha_act			date;
define _ano_actual          integer;
define _total_morosidad     dec(16,2);
define _cod_cober           char(5);
define _flag                smallint;
define _moro_colectivo      dec(16,2);
define _cuenta_cober        smallint;

--JAC 12/08/2014 Se declaran las variales que se usaran para calcular 6 meses atras
define _resultado           date;

begin
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc)||" poliza: "||_no_documento||" no_poliza "||_no_poliza;
end exception

set isolation to dirty read;

--set debug file to "sp_web03.trc";
--trace on;
--Se llama al procedimiento almacenado que nos resta un intervalo de meses a una fecha
--call sp_web31() RETURNING _resultado;

let _compania      = "001";
let _sucursal      = "001";
--let _fecha_moros   = today;
--let _periodo_moros = sp_sis39(_fecha_moros);
let _fecha_act     = current;
let _ano_actual    = year(_fecha_act);

let _moro_exigible	= 0.00;
let _moro_60		= 0.00;
let _moro_corriente	= 0.00;

-- Eliminar Registros de Tablas Temporales

delete from web_consulta_coop;
-- Polizas Vigentes
foreach
	select no_poliza,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_subramo,
		   cod_contratante,
		   cod_sucursal
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_subramo,
		   _cod_contrat,
		   _cod_sucursal
	  from	emipomae
	 where estatus_poliza = 1
	   and cod_ramo = '018'
	   and actualizado = 1
	   and no_documento = '1819-99900-01'
	   --and cod_subramo in ('008','007','009','018','012')
	   --and no_documento in('1816-00237-01')
       --and cod_subramo in ('008','007','009','018','012','014','011')
		--or no_documento in('1817-00129-01','1817-00182-01')
	   --or no_documento in('1816-00237-01')

		if _cod_subramo = '008' then
			let _subramo_desc = "Panama";
		elif _cod_subramo = '007' then
			let _subramo_desc = "Panama Plus";
		elif _cod_subramo = '009' then
			let _subramo_desc = "Global";
		elif _cod_subramo = '018' then
			let _subramo_desc = "Salud Vital";
		elif _cod_subramo = '012' then
			let _subramo_desc = "Colectivo";
		elif _cod_subramo = '014' then
			let _subramo_desc = "Panama Intl";
		elif _cod_subramo = '011' then
			let _subramo_desc = "AA18PAESP1";
		end if

	foreach
		 --Principales
			select cod_asegurado,
				   no_unidad,
				   suma_asegurada
			  into _cod_asegurado,
				   _no_unidad,
				   _suma_asegurada
			  from emipouni
			 where no_poliza = _no_poliza
			   and activo = 1

			select nombre,
				   sexo,
				   fecha_aniversario,
				   telefono1,
				   telefono2,
				   e_mail
			  into _nom_contratante,
				   _sexo,
				   _fecha_aniversario,
				   _telefono1,
				   _telefono2,
				   _email
			  from cliclien
			  where cod_cliente = _cod_asegurado;

				let _flag = 0;
				
				if _fecha_aniversario is not null then
				   let _edad = sp_sis78(_fecha_aniversario,today);
			   	else
			       let _edad = 0;
			   	end if

				if (_sexo = 'F' and _edad >= 35) or (_sexo = 'M' and _edad >= 35) then
					let _dias = 0;
					let _contador = 0;
					let _ano_fec_sini = 0;
					let _flag	= 1;
/*					if _cod_subramo = '012' then
						
						 select count(*)
						  into _cuenta_cober
						  from emipocob
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and cod_cobertura = '00929';

						if _cuenta_cober > 0 Then
							let _flag = 1;
						else
							let _flag = 0;
						end If
						let _flag = 1;	
					else
						let _flag = 1;
					end if 
*/					
					foreach
						select fecha_siniestro,
							   no_reclamo
						  into _fecha_siniestro,
							   _no_reclamo
						  from  recrcmae
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and cod_reclamante = _cod_asegurado 
						   
						select count (*)
						  into _cont_cpt
						  from rectrmae
						 where cod_cpt in('588..','71010+','76091','76092','76094','76400','766452','76801','76902','77051','77055','77055.','77055..','77056','77067','77066.','90019','9630','84153','84154','86849','76499..') --Mamografia, PSA 
						   and no_reclamo =  _no_reclamo;

						if _fecha_siniestro is not null and _cont_cpt > 0 then
				   		   {	let _dias = today - _fecha_siniestro;
							if _dias < 365 then
								let _contador = _contador + 1;
							end if} --se puso en comentario por que Lino solicito que sea una vez al anno 15/09/2010
						   let _ano_fec_sini = year(_fecha_siniestro);
						   if _ano_actual = _ano_fec_sini then
								let _contador = _contador + 1;
						   end if
			   			end if


					end foreach

					if _sexo = 'F' then
						let _procedimiento = 'Mamografia';
					else
						let _procedimiento = 'Antigeno Prostatico(PSA)';
					end if

					if _contador = 0 and _flag = 1 then
					--if _contador = 0 then
						insert into web_consulta_coop(
						num_poliza,
						vigencia_inic,
						vigencia_final,
						nom_asegurado,
						sexo,
						edad,
						planes,
						procedimiento,
						cod_asegurado,
						no_unidad,
						no_poliza,
						cod_contratante,
						suma_asegurada,
						cod_sucursal,
						saldo,
						saldo_60,
						saldo_corriente,
						fecha_aniversario,
						telefono1,
						telefono2,
						email
						)
						values(
						_no_documento,
						_vigencia_inic,
						_vigencia_final,
						_nom_contratante,
						_sexo,
						_edad,
						_subramo_desc,
						_procedimiento,
						_cod_asegurado,
						_no_unidad,
						_no_poliza,
						_cod_contrat,
						_suma_asegurada,
						_cod_sucursal,
						_moro_exigible,
						_moro_60,
						_moro_corriente,
						_fecha_aniversario,
						_telefono1,
					    _telefono2,
					    _email
						);
					end if
				end if
				
			--Dependientes
				foreach

					select cod_cliente
					  into _cod_cliente
					  from emidepen
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					   and activo    = 1

					select nombre,
						   sexo,
						   fecha_aniversario,
						   telefono1,
						   telefono2,
						   e_mail
					  into _nom_contratante,
						   _sexo,
						   _fecha_aniversario,
						   _telefono1,
						   _telefono2,
						   _email
					  from cliclien
					  where cod_cliente = _cod_cliente;
					  
					  let _flag = 0;

						if _fecha_aniversario is not null then
						   let _edad = sp_sis78(_fecha_aniversario,today);
					   	else
					       let _edad = 0;
					   	end if

						if (_sexo = 'F' and _edad >= 35)	 or (_sexo = 'M' and _edad >= 35) then
							let _dias = 0;
							let _contador = 0;
							let _ano_fec_sini = 0;
							let _flag = 1;
								   
							foreach
								select fecha_siniestro,
									   no_reclamo
								  into _fecha_siniestro,
									   _no_reclamo
								  from  recrcmae
								 where no_poliza = _no_poliza
								   and no_unidad = _no_unidad
								   and cod_reclamante = _cod_cliente 
								   
								select count(*)
								  into _cont_cpt
								  from rectrmae
								 where cod_cpt in('588..','71010+','76091','76092','76094','76400','766452','76801','76902','77051','77055','77055.','77055..','77056','77067','77066.','90019','9630','84153','84154','86849','76499..') --Mamografia, PSA
								   and no_reclamo =  _no_reclamo;


								if _fecha_siniestro is not null and _cont_cpt > 0 then
								   {	let _dias = today - _fecha_siniestro;
									if _dias < 365 then
										let _contador = _contador + 1;
									end if}
								   let _ano_fec_sini = year(_fecha_siniestro);
								   if _ano_actual = _ano_fec_sini then
										let _contador = _contador + 1;
								   end if
								end if
							end foreach

							if _sexo = 'F' then
								let _procedimiento = 'Mamografia';
							else
								let _procedimiento = 'Antigeno Prostatico(PSA)';
							end if

							if _contador = 0 and _flag = 1 then
							--if _contador = 0 then
								insert into web_consulta_coop(
								num_poliza,
								vigencia_inic,
								vigencia_final,
								nom_asegurado,
								sexo,
								edad,
								planes,
								procedimiento,
								cod_asegurado,
								no_unidad,
								no_poliza,
								cod_contratante,
								suma_asegurada,
								cod_sucursal,
								saldo,
								saldo_60,
								saldo_corriente,
								fecha_aniversario,
								telefono1,
								telefono2,
								email
								)
								values(
								_no_documento,
								_vigencia_inic,
								_vigencia_final,
								_nom_contratante,
								_sexo,
								_edad,
								_subramo_desc,
								_procedimiento,
								_cod_cliente,
								_no_unidad,
								_no_poliza,
								_cod_contrat,
								_suma_asegurada,
								_cod_sucursal,
								_moro_exigible,
								_moro_60,
								_moro_corriente,
								_fecha_aniversario,
								_telefono1,
							    _telefono2,
							    _email
								);
							end if
					   	end if
				end foreach

    end foreach
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
