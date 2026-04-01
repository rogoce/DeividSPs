-- Procedimiento para consultar pólizas con descuento de pronto pago
-- Creado    : 05/08/2009 - Autor: Roberto Silvera
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro858a;
create procedure "informix".sp_pro858a(a_periodo char(7))
returning 	char(20), 	
			char(255), 	
			date,		
			dec(16,2),  
			char(3),
			char(7),
			dec(16,2),
			date,
			date,
			char(1),
			date;

define v_nombre			char(255);
define _error			char(255);
define v_no_doc			char(20);
define v_no_poliza		char(10);
define _periodo			char(8);
define	v_grupo			char(5);
define	v_cod_formapag	char(3);
define	v_cod_ramo		char(3);
define	v_prima_bruta	dec(16,2);
define	v_prima_modu	dec(16,2);
define	v_saldo_endp	dec(16,2);
define  v_saldo_end		dec(16,2);
define	v_saldo_doc		dec(16,2);
define	v_saldo			dec(16,2);
define	_descuento		dec(16,2);
define	v_zona_libre	smallint;
define  v_existe_end	smallint;
define	_aplica			smallint;
define	v_flag_modu		smallint;
define	v_cant_pag		smallint;
define	v_fecha			date;
define 	v_soda			smallint;
define	v_fecha_susc	date;
define	v_v_inicial		date;
define	v_fech_ult		date;
define	v_v_final		date;
define _cnt,_cnt2       smallint;
define _por_aplicar     char(1);
define _fecha_hoy       date;

let v_fecha = current;
--set debug file to "sp_pro858a.trc";
--trace on;
let _por_aplicar = "";
let _fecha_hoy   = '01/01/1900';
begin
	foreach
		select e.no_poliza,
			   e.cod_ramo,
			   e.prima_bruta,
			   e.cod_formapag,
			   e.fecha_suscripcion,
			   e.no_documento,
			   c.nombre,
			   e.cod_grupo,
			   e.vigencia_inic,
			   e.vigencia_final
		  into v_no_poliza,
			   v_cod_ramo,
			   v_prima_bruta,
			   v_cod_formapag,
			   v_fecha_susc,
			   v_no_doc,
			   v_nombre,
			   v_grupo,
			   v_v_inicial,
			   v_v_final
		  from emipomae e, cliclien c
		 where e.cod_contratante = c.cod_cliente
		   and e.cod_ramo not in ("004", "008", "016", "018", "019", "020")
		   and e.prima_bruta > 100
		   and e.estatus_poliza = 1
		   and e.actualizado = 1
		   and e.serie > 2010
		   
		if v_no_doc = '0904-00924-02' then
			continue foreach;
		end if
		
		call sp_sis402(v_no_poliza,v_fecha,0,'00000') returning _aplica,_error,_descuento;
		
		if _aplica = 0 then
			let v_saldo = sp_cob115c("", "",v_no_doc,"");
			let _periodo = sp_sis39(v_fecha_susc);

			select count(*)
			  into _cnt
			  from cobpronpa
			 where no_poliza = v_no_poliza
			   and seleccionado = 0;

			select count(*)
			  into _cnt2
			  from cobpronde
			 where no_poliza = v_no_poliza
			   and procesado = 0;

            if _cnt > 0 or _cnt2 > 0 then
				let _por_aplicar = '*';
			end if

			foreach
				select max(d.fecha)
				  into _fecha_hoy
				  from cobredet d, cobremae m
				 where d.actualizado  = 1
				   and d.cod_compania = '001'
				   and d.doc_remesa   = v_no_doc
				   and d.tipo_mov     in ('P','N')
				   and d.no_remesa    = m.no_remesa
				   and d.no_poliza    = v_no_poliza
				   and m.tipo_remesa  in ('A', 'M', 'C')

				exit foreach;

			end foreach

			
			return	v_no_doc,
					v_nombre,
					v_fecha_susc,
					v_prima_bruta,
					v_cod_formapag,
					_periodo,
					v_saldo,
					v_v_inicial,
					v_v_final,
					_por_aplicar,
					_fecha_hoy
					with resume;
		end if
	end foreach
end
end procedure
