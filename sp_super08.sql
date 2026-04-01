   --Hoja F - Factor de Zona Geografica
   --Estadistico para la superintendencia
   --  Armando Moreno M. 11/03/2017
   
   DROP procedure sp_super08;
   CREATE procedure sp_super08(a_periodo CHAR(7))
   RETURNING char(50),decimal(16,2),decimal(16,2);

   DEFINE _n_ramo  CHAR(50);
   DEFINE _monto_cancelacion,_monto_rehab dec(16,2);
   DEFINE v_desc_ramo        CHAR(50);
   define _no_documento      char(20);
    
SET ISOLATION TO DIRTY READ;

let _monto_cancelacion = 0.00;
let _monto_rehab	   = 0.00;
let _no_documento      = '';

foreach
	select r.nombre,sum(monto_cancelacion),sum(monto_rehab)
	  into _n_ramo,_monto_cancelacion,_monto_rehab
	  from deivid_cob:tmp_morosidad t, prdramo r
	 where t.cod_ramo = r.cod_ramo
	   and periodo = a_periodo
     group by 1
	 order by 1

	return _n_ramo,_monto_cancelacion,_monto_rehab with resume;
end foreach

{foreach	with hold
	select distinct poliza
	  into _no_documento
	  from deivid_tmp:temp_venc2018jun

	let _monto_rehab	   = sp_cob174(_no_documento);
	if _monto_rehab <> 0 then
		return _no_documento,_monto_rehab,0.00 with resume;
	end if
end foreach}

END PROCEDURE;