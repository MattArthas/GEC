package cc.zero.travel.model;

import java.util.Date;

public class Topic {

	private int id;
	/**
	 * ���µı���
	 */
	private String title;
	/**
	 * ���µ�����
	 */
	private String content;
	/**
	 * ���µĴ�������
	 */
	private Date createdate;
	/**
	 * ���µ�����
	 */
	private String username;
	/**
	 * �������ĸ�ģ�鷢��������������������ι���,���γ�ʶ,��վ����
	 */
	private String channelType;
	/**
	 * �����Ƿ񷢲���0��������1��ʾ����
	 */
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public Date getCreatedate() {
		return createdate;
	}
	public void setCreatedate(Date createdate) {
		this.createdate = createdate;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getChannelType() {
		return channelType;
	}
	public void setChannelType(String channelType) {
		this.channelType = channelType;
	}
	
	
}
