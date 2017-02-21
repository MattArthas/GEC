package cc.zero.travel.model;

import java.util.Date;

public class Topic {

	private int id;
	/**
	 * 文章的标题
	 */
	private String title;
	/**
	 * 文章的内容
	 */
	private String content;
	/**
	 * 文章的创建日期
	 */
	private Date createdate;
	/**
	 * 文章的作者
	 */
	private String username;
	/**
	 * 文章在哪个模块发布，简单起见，定义了旅游攻略,旅游常识,网站公告
	 */
	private String channelType;
	/**
	 * 文章是否发布，0不发布，1表示发布
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
